# Contributing to TensorFlow Lite Plus

Thank you for your interest in contributing to TensorFlow Lite Plus! This document outlines the guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

1. **Search existing issues** first to avoid duplicates
2. **Use the issue template** when creating new issues
3. **Provide detailed information** including:
   - Flutter version
   - Platform (Android/iOS)
   - Device information
   - Steps to reproduce
   - Expected vs actual behavior
   - Code samples or screenshots

### Suggesting Features

1. **Check the roadmap** to see if the feature is already planned
2. **Create a feature request** with:
   - Clear description of the feature
   - Use case and benefits
   - Proposed API design (if applicable)
   - Implementation considerations

### Code Contributions

#### Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/tflite_plus.git
   cd tflite_plus
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   cd example && flutter pub get
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

#### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Write clean code** following our coding standards:
   - Use proper Dart formatting (`dart format`)
   - Add comprehensive documentation
   - Follow existing code patterns
   - Add tests for new functionality

3. **Test your changes**
   ```bash
   # Run all tests
   flutter test
   
   # Test on both platforms
   cd example
   flutter run # Android
   flutter run -d ios # iOS (macOS only)
   ```

4. **Update documentation**
   - Update README.md if needed
   - Add/update API documentation
   - Update CHANGELOG.md

#### Code Style Guidelines

- **Dart**: Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **Android**: Follow [Android Kotlin Style Guide](https://developer.android.com/kotlin/style-guide)
- **iOS**: Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

#### Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
- `feat(android): add GPU delegate support`
- `fix(ios): resolve memory leak in model loading`
- `docs(readme): add pose estimation examples`

#### Pull Request Process

1. **Ensure all tests pass**
2. **Update documentation** as needed
3. **Create a pull request** with:
   - Clear title and description
   - Reference related issues
   - List of changes made
   - Screenshots/GIFs for UI changes

4. **Respond to feedback** promptly
5. **Maintain a clean commit history**

## Development Guidelines

### Architecture

The plugin follows a layered architecture:

```
┌─────────────────────┐
│    Dart API         │  ← Public API
├─────────────────────┤
│  Platform Interface │  ← Abstract interface
├─────────────────────┤
│   Method Channel    │  ← Implementation
├─────────────────────┤
│  Native Platforms   │  ← Android/iOS
└─────────────────────┘
```

### Adding New Features

1. **Update the platform interface**
   ```dart
   abstract class TflitePlusPlatform {
     Future<ReturnType?> newFeature(Parameters params);
   }
   ```

2. **Implement in method channel**
   ```dart
   class MethodChannelTflitePlus {
     Future<ReturnType?> newFeature(Parameters params) async {
       return await methodChannel.invokeMethod('newFeature', params.toMap());
     }
   }
   ```

3. **Add to main API**
   ```dart
   class TflitePlus {
     static Future<ReturnType?> newFeature(Parameters params) {
       return TflitePlusPlatform.instance.newFeature(params);
     }
   }
   ```

4. **Implement native code**
   - Android: Update `TflitePlusPlugin.kt`
   - iOS: Update `TflitePlusPlugin.swift`

5. **Add comprehensive tests**
6. **Update documentation**

### Testing Guidelines

#### Unit Tests
- Test all public APIs
- Mock platform-specific code
- Test error handling
- Aim for >90% code coverage

#### Integration Tests
- Test on real devices
- Test with actual models
- Test hardware acceleration
- Test memory management

#### Example Tests
```dart
test('loadModel should return success message', () async {
  final result = await TflitePlus.loadModel(
    model: 'test_model.tflite',
  );
  expect(result, contains('success'));
});
```

### Documentation Standards

- **API Documentation**: Use proper dartdoc comments
- **README Updates**: Keep examples current
- **Code Comments**: Explain complex logic
- **Changelog**: Document all changes

## Community Guidelines

### Code of Conduct

This project follows a Code of Conduct. By participating, you agree to:

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Maintain professional communication
- Respect different viewpoints

### Getting Help

- **Documentation**: Check README and API docs first
- **Issues**: Search existing issues
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact support@codebumble.net for private matters

## Recognition

Contributors will be:
- Listed in the Contributors section
- Mentioned in release notes for significant contributions
- Invited to join the maintainer team for exceptional contributions

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make TensorFlow Lite Plus better for everyone! 🚀