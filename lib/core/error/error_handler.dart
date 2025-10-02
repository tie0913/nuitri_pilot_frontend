
import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';

abstract interface class ErrorHandler{
  /*
   * 公共的错误处理器，当出现网络中的各种异常时会走这个逻辑
   */
  void handleErr(Err e);
  /*
   * 针对业务错误，如果没什么特殊逻辑，也可以使用这个方法统一处理，底层和公共错误处理器是一样的
   */
  void handleBizErr(BizErr bizErr);


  void handleBothError(Result e);
}


class GlobalErrorHandler implements ErrorHandler{

  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  GlobalErrorHandler({required this.navigatorKey, required this.messengerKey});

  
  @override
  void handleErr(Err e) {
    showErrMessage(e.message);
  }
  
  @override
  void handleBizErr(BizErr bizErr) {
    showErrMessage(bizErr.message);
  }


  void showErrMessage(String message){

    //首选：不用 context，直接用全局 ScaffoldMessenger
    final m = messengerKey.currentState;
    if (m != null) {
      m.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    //兜底：等首帧后再用 navigator 的 context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
      }
    });

  }
  
  @override
  void handleBothError(Result e) {
    if(e is Err){
      handleErr(e);
    }else if(e is BizErr){
      handleBizErr(e);
    }
  }


   // 退而求其次：首帧后再取 navigator 的 context
    
}