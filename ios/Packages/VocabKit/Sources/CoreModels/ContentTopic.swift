import Foundation

/// One topic the user can choose to study: a `category` row (contract section 3) with at least
/// one card the app shows among its members (`card_category`).
public struct ContentTopic: Hashable, Sendable, Identifiable {
    /// `category.id`, for example "travel_tourism".
    public let id: String
    /// `category.grp`, "A" ... "I" (everyday life, travel, people, work, ...).
    public let group: String
    public let nameEN: String
    /// `category.name_tr` as the content has it ("Yeme & İçme"). Screens show `displayName`.
    public let nameTR: String
    /// `category.sort`: display order.
    public let sort: Int
    /// Free, non-sensitive member cards (main topic or not; a card can be in several topics).
    public let cardCount: Int

    public init(id: String, group: String, nameEN: String, nameTR: String, sort: Int, cardCount: Int) {
        self.id = id
        self.group = group
        self.nameEN = nameEN
        self.nameTR = nameTR
        self.sort = sort
        self.cardCount = cardCount
    }
}

extension ContentTopic {
    /// The name shown in the app: short everyday Turkish with "ve" instead of "&" (A2 reader).
    /// The content (`category.name_tr`) stays as it is; a new topic shows its own name.
    /// One name on every screen: the topic choice (onboarding, Ayarlar > Konular), Sözlük's
    /// "Konuya göre göz at" and topic page, and İlerleme's topic rows (`WordGroup.topics`).
    public var displayName: String {
        switch id {
        case "food_drink": return "Yemek ve içecek"
        case "home_household": return "Ev ve ev işleri"
        case "family_relationships": return "Aile"
        case "clothes_fashion": return "Giyim"
        case "shopping_money": return "Alışveriş ve para"
        case "health_body": return "Sağlık ve vücut"
        case "cities_transport": return "Şehir ve ulaşım"
        case "weather_seasons": return "Hava ve mevsimler"
        case "time_routines": return "Zaman ve günlük işler"
        case "hobbies_sports": return "Hobi ve spor"
        case "school_learning": return "Okul"
        case "nature_animals": return "Doğa ve hayvanlar"
        case "travel_tourism": return "Seyahat"
        case "culture_celebrations": return "Ülkeler ve kültür"
        case "music_film": return "Müzik ve film"
        case "art_design_architecture": return "Sanat"
        case "emotions_feelings": return "Duygular"
        case "personality": return "Kişilik"
        case "social_skills": return "Sohbet"
        case "love_friendship": return "Aşk ve arkadaşlık"
        case "opinions_debate": return "Fikir ve tartışma"
        case "success_productivity": return "Başarı ve motivasyon"
        case "business_management": return "İş dünyası"
        case "workplace_office": return "İş yerinde"
        case "careers_interviews": return "İş görüşmesi"
        case "finance_economics": return "Para ve ekonomi"
        case "technology_internet": return "Teknoloji ve internet"
        case "phrasal_verbs": return "Kalıp fiiller"
        case "idioms_expressions": return "Deyimler"
        case "collocations": return "Kelime ikilileri"
        case "confusing_words": return "Karıştırılan kelimeler"
        // Topics without cards today: named here so a later content build is not in title case.
        case "compliments_insults": return "İltifat ve laf sokma"
        case "slang_informal": return "Argo ve gündelik dil"
        case "society_media": return "Toplum ve haberler"
        case "environment_climate": return "Çevre ve iklim"
        default: return nameTR.replacingOccurrences(of: " & ", with: " ve ")
        }
    }

    /// The title over the topic in the topic choice (`TopicGroup`), by `group` (`category.grp`).
    /// Groups with one or two topics share a title with a neighbour (B and F, D and E). "I" is the
    /// exam topics ("YDS / YÖKDİL Çekirdek"): a title of its own, even over a single topic, so an
    /// exam deck is never mistaken for an everyday one.
    public var groupTitle: String {
        switch group {
        case "A": return "Günlük hayat"
        case "B", "F": return "Seyahat ve kültür"
        case "C": return "İnsanlar ve duygular"
        case "D", "E": return "İş ve teknoloji"
        case "G": return "Kalıplar ve tuzaklar"
        case "H": return "Zengin kelimeler"
        case "I": return "Sınavlar"
        default: return "Diğer"
        }
    }
}
