import 'package:flutter/material.dart';

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final String routeName;

  SlidePageRoute({required this.page, required this.routeName})
      : super(
    settings: RouteSettings(name: routeName),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 2600),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {

      final overlayFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.10, curve: Curves.easeIn),
        ),
      );

      final overlayFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.90, 1.0, curve: Curves.fastOutSlowIn),
        ),
      );

      final iconEntry = Tween<Offset>(
        begin: const Offset(0.0, 0.4),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.08, 0.35, curve: Cubic(0.2, 0.8, 0.2, 1.0)),
        ),
      );

      final scannerTimeline = Tween<double>(begin: -1.0, end: 1.5).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.30, 0.75, curve: Curves.easeInOut),
        ),
      );

      final iconScaleOut = Tween<double>(begin: 1.0, end: 14.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.82, 0.94, curve: Cubic(0.7, 0.0, 0.5, 1.0)),
        ),
      );

      final textProgress = animation.value;
      String loadingText = "Verificando credenciales...";
      if (textProgress > 0.50) loadingText = "Analizando perfil...";
      if (textProgress > 0.78) loadingText = "¡Acceso concedido!";

      return Stack(
        children: [
          child,

          IgnorePointer(
            ignoring: animation.isCompleted,
            child: FadeTransition(
              opacity: overlayFadeIn,
              child: FadeTransition(
                opacity: overlayFadeOut,
                child: Scaffold(
                  backgroundColor: const Color(0xFF1565C0),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: iconScaleOut,
                          child: SlideTransition(
                            position: iconEntry,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.account_circle_rounded,
                                    size: 68,
                                    color: Colors.white,
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: scannerTimeline,
                                  builder: (context, _) {
                                    return Positioned(
                                      top: 60 + (scannerTimeline.value * 45),
                                      left: 15,
                                      right: 15,
                                      child: Opacity(
                                        opacity: (scannerTimeline.value > -0.7 && scannerTimeline.value < 1.2) ? 1.0 : 0.0,
                                        child: Container(
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00E5FF),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF00E5FF).withOpacity(0.8),
                                                blurRadius: 10,
                                                spreadRadius: 1.5,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            loadingText,
                            key: ValueKey<String>(loadingText),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 140,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF7F9FC)),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}