class PromptRequest {
  final String id;
  final String version;
  final Map<String, dynamic> variables;
  final String? instructions;

  const PromptRequest({
    required this.id,
    required this.version,
    required this.variables,
    this.instructions,
  });

  factory PromptRequest.fromJson(Map<String, dynamic> json) {
    final promptData = json['prompt'] as Map<String, dynamic>;
    return PromptRequest(
      id: promptData['id'] as String,
      version: promptData['version'] as String,
      variables: promptData['variables'] as Map<String, dynamic>,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt': {'id': id, 'version': version, 'variables': variables},
      if (instructions != null) 'instructions': instructions,
    };
  }
}
