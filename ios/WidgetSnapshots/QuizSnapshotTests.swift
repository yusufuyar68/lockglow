import XCTest
import SwiftUI
import UIKit
import CoreModels

/// Renders the "Tekrar" quiz card (App/QuizCardView.swift, compiled into this bundle) in its three
/// states on an iPhone SE width, for CI layout review: not answered, answered right, answered wrong.
@MainActor
final class QuizSnapshotTests: XCTestCase {
    private let cases: [(WidgetWord, CardDetail.Quiz)] = [
        (
            WidgetWord(id: 2, lemma: "spoon", pos: "n", level: "A1", defMicro: "tool for eating soup",
                       defShort: "a small tool with a round end, used to eat soup or stir tea", exampleEN: "Can I have a spoon, please?", glossTR: "kaşık"),
            CardDetail.Quiz(cloze: "I eat soup with a ______, not with a fork.", answer: "spoon",
                            distractors: ["knife", "plate", "cup"])
        ),
        (
            WidgetWord(id: 452, lemma: "lyrics", pos: "n", level: "B1", defMicro: "words of a song",
                       defShort: "the words that a person sings in a song", exampleEN: "I love this song, but I don't know the lyrics.", glossTR: "şarkı sözleri"),
            CardDetail.Quiz(cloze: "I like the music, but I can't understand the ______ because they sing too fast.", answer: "lyrics",
                            distractors: ["tickets", "trailers", "playlists"])
        ),
    ]

    func testRenderQuizStates() throws {
        for (word, quiz) in cases {
            let wrong = quiz.distractors.first
            render(QuizCardView(word: word, quiz: quiz) { _ in }, name: "quiz-\(word.lemma)-soru")
            render(QuizCardView(word: word, quiz: quiz, initialPick: quiz.answer) { _ in }, name: "quiz-\(word.lemma)-dogru")
            render(QuizCardView(word: word, quiz: quiz, initialPick: wrong) { _ in }, name: "quiz-\(word.lemma)-yanlis")
        }
    }

    private func render<V: View>(_ view: V, name: String) {
        let content = view
            .padding(16)
            .frame(width: 375)
            .background(Color.white)
            .environment(\.colorScheme, .light)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 2
        guard let image = renderer.uiImage else {
            XCTFail("could not render \(name)")
            return
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
