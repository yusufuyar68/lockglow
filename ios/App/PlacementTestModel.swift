import Foundation
import CoreModels
import Learning

// "Seviye testi" (PlacementTestView.swift): what the test reads from the model and the one thing
// it changes, the start level. Foundation only, so it joins the Linux compile check
// (ios/Tools/linux_check_prepare.py `APP_LOGIC_FILES`).

extension AppModel {
    /// Cards the test may ask, by level: A1–B2 cards with a Turkish meaning, never a personal-topic
    /// card or the user's own word. B2 is asked only when there are enough B2 cards
    /// (`PlacementTest.levels(for:)`); with too few the test gives A1, A2 or B1.
    func placementBank() -> [Level: [Int]] {
        var bank: [Level: [Int]] = [:]
        for word in placementCandidates {
            guard let level = word.levelValue, PlacementTest.allLevels.contains(level) else {
                continue
            }
            bank[level, default: []].append(word.id)
        }
        return bank
    }

    /// The test can be offered: the content is still loading (the sheet waits for it) or it has
    /// enough cards. Seed words alone are too few.
    var canOfferPlacementTest: Bool {
        return contentSource == .loading || PlacementTest.canRun(bank: placementBank())
    }

    /// The question for a test word: the English word and four Turkish meanings ("Anlamını seç",
    /// the same options as "Hatırla"; a confusable partner is never an option). Nil when the card
    /// cannot get four meanings: the test then takes the next word.
    func placementQuestion(for id: Int) -> ChoiceQuestion? {
        guard let word = self.word(id: id) else {
            return nil
        }
        let question = ReviewPlanner.introQuestion(
            for: word,
            direction: .pickMeaning,
            attempt: 1,
            writtenDistractors: [],
            candidates: placementCandidates,
            topicsOf: topicsOf,
            excludedIDs: Set(word.confusableIDs ?? [])
        )
        guard let question = question,
              question.direction == .pickMeaning,
              question.options.count == ReviewPlanner.choiceCount else {
            return nil
        }
        return question
    }

    /// The test's result becomes the start level; a daily goal the user never chose follows it
    /// (A1–A2: 5, B1–B2: 10), as in "Ayarlar". Only the level: no word is marked known and no
    /// progress is written.
    func applyPlacementResult(_ level: Level) {
        setStartLevel(level)
        setDailyNewWords(AppPreferences.dailyNewWords)
    }

    private var placementCandidates: [WidgetWord] {
        return words.filter { word in
            !word.isUserAdded && !word.isSensitive && !(word.glossTR ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
}
