# Windows 构建指南

## 问题解决

如果您在Windows上运行 `flutter run -d windows` 时遇到以下错误：

```
CUSTOMBUILD : error : unable to find directory entry in pubspec.yaml: assets\images\
CUSTOMBUILD : error : unable to find directory entry in pubspec.yaml: assets\icons\
CUSTOMBUILD : error : unable to find directory entry in pubspec.yaml: assets\themes\
```

这是因为 `pubspec.yaml` 文件中引用了空的资源目录。Flutter 不允许引用空的资源目录。

## 解决方案

我们已经修复了这个问题。如果您仍然遇到问题，请按照以下步骤操作：

### 1. 清理项目
```bash
flutter clean
```

### 2. 重新获取依赖
```bash
flutter pub get
```

### 3. 运行应用
```bash
flutter run -d windows
```

## Windows 构建要求

确保您的系统满足以下要求：

### 系统要求
- Windows 10 或更高版本
- Visual Studio 2022 或 Visual Studio Build Tools 2022
- Flutter SDK 3.5.4 或更高版本

### Visual Studio 组件
确保安装了以下组件：
- MSVC v143 - VS 2022 C++ x64/x86 build tools
- Windows 10/11 SDK
- CMake tools for Visual Studio

### 验证环境
运行以下命令验证您的开发环境：
```bash
flutter doctor -v
```

确保 Windows 平台显示为可用。

## 构建发布版本

### 构建 Windows 可执行文件
```bash
flutter build windows --release
```

构建完成后，可执行文件将位于：
```
build\windows\x64\runner\Release\
```

### 分发应用
要分发您的应用，您需要包含以下文件：
- `mydiary_flutter.exe` - 主可执行文件
- `flutter_windows.dll` - Flutter 运行时
- `data/` 文件夹 - 包含应用资源

## 常见问题

### 1. Visual Studio 未找到
如果遇到 Visual Studio 相关错误，请确保：
- 安装了 Visual Studio 2022 或 Build Tools
- 安装了必要的 C++ 组件
- 重启命令提示符

### 2. CMake 错误
如果遇到 CMake 相关错误：
- 确保安装了 CMake
- 将 CMake 添加到系统 PATH
- 重启 IDE 或命令提示符

### 3. 权限问题
如果遇到权限相关错误：
- 以管理员身份运行命令提示符
- 确保项目文件夹有写入权限

## 性能优化

### 发布模式构建
始终使用 `--release` 标志构建生产版本：
```bash
flutter build windows --release
```

### 减小应用大小
- 移除未使用的依赖
- 使用 `flutter build windows --split-debug-info` 分离调试信息
- 考虑使用 `--obfuscate` 进行代码混淆

## 调试

### 调试模式运行
```bash
flutter run -d windows --debug
```

### 查看日志
```bash
flutter logs
```

### 性能分析
```bash
flutter run -d windows --profile
```

## 支持

如果您遇到其他问题，请：
1. 检查 Flutter 官方文档
2. 运行 `flutter doctor` 检查环境
3. 查看项目的 GitHub Issues
4. 确保使用最新版本的代码

---

**注意**: 这个修复已经包含在最新的代码中。如果您从 GitHub 克隆了最新版本，应该不会遇到这些问题。