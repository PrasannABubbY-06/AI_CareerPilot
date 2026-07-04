import 'dart:convert';

class ResourceLink {
  final String title;
  final String url;

  ResourceLink({required this.title, required this.url});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
    };
  }

  factory ResourceLink.fromMap(Map<String, dynamic> map) {
    return ResourceLink(
      title: map['title'] ?? '',
      url: map['url'] ?? '',
    );
  }
}

class ResourcePackModel {
  final String skillName;
  final List<ResourceLink> youtubeVideos;
  final List<ResourceLink> officialDocs;
  final List<ResourceLink> freeWebsites;
  final List<ResourceLink> practicePlatforms;
  final List<ResourceLink> githubRepos;
  final List<ResourceLink> miniProjects;

  ResourcePackModel({
    required this.skillName,
    required this.youtubeVideos,
    required this.officialDocs,
    required this.freeWebsites,
    required this.practicePlatforms,
    required this.githubRepos,
    required this.miniProjects,
  });

  Map<String, dynamic> toMap() {
    return {
      'skillName': skillName,
      'youtubeVideos': youtubeVideos.map((x) => x.toMap()).toList(),
      'officialDocs': officialDocs.map((x) => x.toMap()).toList(),
      'freeWebsites': freeWebsites.map((x) => x.toMap()).toList(),
      'practicePlatforms': practicePlatforms.map((x) => x.toMap()).toList(),
      'githubRepos': githubRepos.map((x) => x.toMap()).toList(),
      'miniProjects': miniProjects.map((x) => x.toMap()).toList(),
    };
  }

  factory ResourcePackModel.fromMap(Map<String, dynamic> map) {
    return ResourcePackModel(
      skillName: map['skillName'] ?? '',
      youtubeVideos: List<ResourceLink>.from(
        (map['youtubeVideos'] as List<dynamic>? ?? []).map((x) => ResourceLink.fromMap(x)),
      ),
      officialDocs: List<ResourceLink>.from(
        (map['officialDocs'] as List<dynamic>? ?? []).map((x) => ResourceLink.fromMap(x)),
      ),
      freeWebsites: List<ResourceLink>.from(
        (map['freeWebsites'] as List<dynamic>? ?? []).map((x) => ResourceLink.fromMap(x)),
      ),
      practicePlatforms: List<ResourceLink>.from(
        (map['practicePlatforms'] as List<dynamic>? ?? []).map((x) => ResourceLink.fromMap(x)),
      ),
      githubRepos: List<ResourceLink>.from(
        (map['githubRepos'] as List<dynamic>? ?? []).map((x) => ResourceLink.fromMap(x)),
      ),
      miniProjects: List<ResourceLink>.from(
        (map['miniProjects'] as List<dynamic>? ?? []).map((x) => ResourceLink.fromMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ResourcePackModel.fromJson(String source) => ResourcePackModel.fromMap(json.decode(source));
}
