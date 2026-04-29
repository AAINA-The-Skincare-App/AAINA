import Foundation

struct ArticleContent: Codable {
    let articleID: String
    let readTime: String
    let headerBadges: [String]
    let sections: [ArticleSection]

    enum CodingKeys: String, CodingKey {
        case articleID = "article_id"
        case readTime = "read_time"
        case headerBadges = "header_badges"
        case sections
    }
}

struct ArticleSection: Codable {
    let heading: String
    let type: ArticleSectionType
    let content: String?
    let pills: [String]?
    let items: [ArticleCardItem]?
    let steps: [ArticleTimelineStep]?
    let alertBox: ArticleCardItem?
    let bottomCards: [ArticleCardItem]?
    let sources: [ArticleSource]?

    enum CodingKeys: String, CodingKey {
        case heading
        case type
        case content
        case pills
        case items
        case steps
        case alertBox = "alert_box"
        case bottomCards = "bottom_cards"
        case sources
    }
}

enum ArticleSectionType: String, Codable {
    case introCard = "intro_card"
    case gridCards = "grid_cards"
    case timeline
    case infoGroup = "info_group"
    case sourcesList = "sources_list"
}

struct ArticleCardItem: Codable {
    let icon: String?
    let title: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case icon = "sf_symbol"
        case title
        case description
    }
}

struct ArticleTimelineStep: Codable {
    let label: String
    let color: String
    let text: String
}

struct ArticleSource: Codable {
    let title: String
    let sourceTag: String

    enum CodingKeys: String, CodingKey {
        case title
        case sourceTag = "source_tag"
    }
}

enum ArticleStore {
    static func article(withID id: String) -> ArticleContent? {
        loadArticles().first { $0.articleID == id }
    }

    private static func loadArticles() -> [ArticleContent] {
        guard
            let url = Bundle.main.url(forResource: "Articles", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else { return [] }

        return (try? JSONDecoder().decode([ArticleContent].self, from: data)) ?? []
    }
}
