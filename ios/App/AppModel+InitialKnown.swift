import Foundation
import CoreModels
import Learning

/// A fixed offered list and its baseline. Retain it when going back from the widget guide;
/// a new level/topic choice creates a new session instead of reinterpreting old checkboxes.
struct OnboardingKnownSession {
    let words: [WidgetWord]
    let baselineProgress: [Int: WordProgress]
    let candidateIDs: Set<Int>
    let selectedIDs: Set<Int>
}

extension AppModel {
    /// Only unchanged initial-source claims are excluded from the feed's opening snapshot.
    /// An ordinary "Biliyorum" or a later answer never adds an ID to this set.
    var initialKnownWordIDs: Set<Int> {
        guard !initialKnownRequiresInvalidation,
              !UserDefaults.standard.bool(forKey: "lockglow.initialKnownInvalidationPending"),
              initialKnownStore?.isReady == true,
              let claims = initialKnownClaims else {
            return []
        }
        return Set(claims.compactMap { id, claim in
            progress[id] == claim.marked ? id : nil
        })
    }

    func onboardingKnownSession(for choice: DeckChoice) -> OnboardingKnownSession {
        ingestWidgetEvents()
        guard readyInitialKnownStore() != nil else {
            return OnboardingKnownSession(words: [], baselineProgress: progress, candidateIDs: [], selectedIDs: [])
        }
        let active = initialKnownWordIDs
        var seen = Set<Int>()
        // Match rebuildFeed: the user's words join every topic/level before the content cards.
        let cards = words.filter { !$0.isUserAdded }
        let ordered = withCustomWords(DeckFilter.feed(cards, topicsOf: topicsOf, choice: choice))
        let offered = ordered.filter { word in
            guard seen.insert(word.id).inserted else { return false }
            if active.contains(word.id) { return true }
            guard let record = progress[word.id] else { return true }
            return record.state == .new && record.reviews == 0
        }
        let sample = Array(offered.prefix(10))
        let ids = Set(sample.map(\.id))
        return OnboardingKnownSession(
            words: sample, baselineProgress: progress, candidateIDs: ids,
            selectedIDs: active.intersection(ids)
        )
    }

    /// The known-word batch commits before settings. Nil skips it; an empty set deliberately
    /// clears the offered initial claims. A failed write leaves the caller on the same page.
    @discardableResult
    func applyOnboardingChoices(
        choice: DeckChoice, explicitDailyChoice: Int?, knownSelection: Set<Int>?,
        session: OnboardingKnownSession?, now: Date = Date()
    ) -> Bool {
        ingestWidgetEvents()
        setOnboardingChoiceFeedback()
        guard explicitDailyChoice.map({ AppPreferences.dailyNewWordChoices.contains($0) }) ?? true,
              choice.startLevel.map({ AppPreferences.startLevelChoices.contains($0) }) ?? true,
              now.timeIntervalSince1970.isFinite else {
            setOnboardingChoiceFeedback(error: "Seçimler geçerli değil. Yeniden seçip dene.")
            return false
        }

        var protectedIDs = Set<Int>()
        if let selected = knownSelection {
            guard isProgressReadyForSync,
                  let session = session,
                  session.candidateIDs == Set(session.words.map(\.id)),
                  selected.isSubset(of: session.candidateIDs),
                  let metadata = readyInitialKnownStore(),
                  let claims = metadata.claims else {
                setOnboardingChoiceFeedback(error: "Başlangıç seçimleri kaydedilemiyor. İlerlemen korundu; yeniden dene.")
                return false
            }
            let plan = InitialKnownSelectionPlanner.plan(
                offeredIDs: session.candidateIDs, baselineProgress: session.baselineProgress,
                selectedIDs: selected, currentProgress: progress, claims: claims, now: now
            )
            do {
                // Provenance first: a crash can leave an inactive claim, never an untracked
                // automatic known record that could later be mistaken for a manual choice.
                try metadata.saveBeforeProgress(plan.claims)
                adoptInitialKnownClaims(plan.claims)
            } catch {
                // A failed write may also mean the file changed since this owner's load.
                // Read it again for a safe retry; never overwrite an unreadable replacement.
                adoptInitialKnownClaims(try? metadata.load())
                setOnboardingChoiceFeedback(error: "Seçimlerin kaydedilemedi. Önceki ilerlemen ve tercihler korundu.")
                return false
            }
            guard replaceProgress(plan.updatedProgress) else {
                setOnboardingChoiceFeedback(error: "Seçimlerin kaydedilemedi. Önceki ilerlemen ve tercihler korundu; yeniden dene.")
                return false
            }
            dismissKnownUndo()
            protectedIDs = plan.protectedIDs
        }

        setDeckChoice(choice)
        if let count = explicitDailyChoice {
            // A tap on the default number is still an explicit preference.
            AppPreferences.chooseDailyNewWords(count)
            setDailyNewWords(count)
        } else {
            setDailyNewWords(AppPreferences.dailyNewWords)
        }
        if !protectedIDs.isEmpty {
            setOnboardingChoiceFeedback(notice: "Bu sırada çalıştığın \(protectedIDs.count) kelimenin ilerlemesi korundu.")
        }
        return true
    }

    /// Progress recovery never carries automatic-selection authority across file generations.
    /// Metadata failure blocks only this optional feature, not the main progress store.
    func loadInitialKnownProvenance(progressURL: URL, outcome: ProgressStore.LoadOutcome) -> Bool {
        if initialKnownStore == nil {
            initialKnownStore = InitialKnownSelectionStore(
                fileURL: progressURL.deletingLastPathComponent().appendingPathComponent("initial_known_claims.json")
            )
        }
        switch outcome {
        case .fresh, .restoredFromBackup, .startedOver:
            return invalidateInitialKnownProvenance()
        case .loaded:
            _ = readyInitialKnownStore()
            return true
        }
    }

    /// Import/reset must discard source authority before changing the primary. If removal is
    /// blocked, retain the progress and retry invalidation before accepting another selection.
    @discardableResult
    func invalidateInitialKnownProvenance() -> Bool {
        initialKnownRequiresInvalidation = true
        UserDefaults.standard.set(true, forKey: "lockglow.initialKnownInvalidationPending")
        adoptInitialKnownClaims(nil)
        guard let metadata = initialKnownStore else {
            initialKnownRequiresInvalidation = false
            UserDefaults.standard.removeObject(forKey: "lockglow.initialKnownInvalidationPending")
            return true
        }
        do {
            try metadata.clear()
            initialKnownRequiresInvalidation = false
            UserDefaults.standard.removeObject(forKey: "lockglow.initialKnownInvalidationPending")
            adoptInitialKnownClaims([:])
            return true
        } catch {
            setOnboardingChoiceFeedback(error: "Başlangıç seçim kaydı temizlenemedi. Mevcut ilerlemen korundu; yeniden dene.")
            return false
        }
    }

    private func readyInitialKnownStore() -> InitialKnownSelectionStore? {
        guard let metadata = initialKnownStore else {
            setOnboardingChoiceFeedback(error: "Başlangıç seçim kaydı hazır değil. İlerlemen korundu; bu adımı atlayabilirsin.")
            return nil
        }
        let pending = initialKnownRequiresInvalidation || UserDefaults.standard.bool(forKey: "lockglow.initialKnownInvalidationPending")
        if pending && !invalidateInitialKnownProvenance() { return nil }
        do {
            if !metadata.isReady { try metadata.load() }
            adoptInitialKnownClaims(metadata.claims)
            return metadata
        } catch {
            adoptInitialKnownClaims(nil)
            setOnboardingChoiceFeedback(error: "Başlangıç seçim kaydı okunamadı. İlerlemen korundu; bu adımı atlayabilirsin.")
            return nil
        }
    }
}
