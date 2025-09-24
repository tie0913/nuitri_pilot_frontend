// lib/core/di.dart
import '../features/auth/data/local_auth_data_source.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';

/// 这个是组合模式依赖管理的类，使用这个类，把所有组件的构建组合放在一起
/// 这样，就模拟了Spring中的依赖注入功能。
/// 
/// 代码中关于 authRepo和localAuthDS的例子就是当对外提供用户是否登录的判定是给做了两层
/// 一层走本地，一层走网络。这样方式未来在扩展功能或修改时，在使用方看来是不变化的，因为接口签名没有变化
/// 但用这个代码来解释依赖注入有些牵强了，因为它杂糅了装饰/代理模式
/// 
/// This is Dependencies Injection Class
/// It does not care about anything but composing all the components together
/// so that we can decouple different layers 
class DI {
  DI._();
  static final DI I = DI._();

  late final LocalAuthDataSource _localAuthDS;
  late final AuthRepository _authRepo;

  AuthRepository get authRepo => _authRepo;

  /// 在应用启动时调用一次。
  void init() {
    _localAuthDS = LocalAuthDataSource();
    _authRepo = AuthRepositoryImpl(_localAuthDS);

    // ------------------------------------------------------------
    // <-- 这里注册鉴权（如果你有全局拦截器/路由守卫要用到 authRepo）
    // 例：AuthInterceptor.getToken = () async => await _localAuthDS.readToken();
    //     AuthInterceptor.refreshToken = () async => await _authRepo.refreshToken();
    // 目前我们先不接 http 拦截器，专注路由鉴权即可。
    // ------------------------------------------------------------
  }
}
