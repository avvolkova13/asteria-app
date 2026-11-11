part of '../app_route.dart';

class HomeProfileRoute extends AppRoute {
  static const routeName = '/home/profile';

  HomeProfileRoute()
    : super(
        name: routeName,
        path: 'profile',
        routes: [ProfileAvatarRoute()],
        pageBuilder: (context, state) => AsteriaPage<void>(
          name: routeName,
          key: state.pageKey,
          child: const ProfileScreen(canPop: true),
        ),
      );

  static void push(BuildContext context) => context.pushNamed(routeName);
}

class ProfileAvatarRoute extends AppRoute {
  static const routeName = '/home/profile/avatar';

  ProfileAvatarRoute()
    : super(
        name: routeName,
        path: 'avatar',
        pageBuilder: (context, state) {
          final user = context.read<UserProvider>().currentUser;
          return AsteriaPage<void>(
            name: routeName,
            key: state.pageKey,
            child: AvatarPickerScreen(
              userId: user?.id ?? '',
              gender: user?.personalInfo?.gender,
            ),
          );
        },
      );

  static void push(BuildContext context) => context.pushNamed(routeName);
}

class ProfileRoutes {
  static const profilePaymentRouteName = '/profile/payment';
  static final profilePaymentRoute = ProfilePaymentRoute();

  static List<AppRoute> get routes => [profilePaymentRoute];
}

class ProfilePaymentRoute extends AppRoute {
  ProfilePaymentRoute()
    : super(
        name: ProfileRoutes.profilePaymentRouteName,
        path: ProfileRoutes.profilePaymentRouteName,
        pageBuilder: (context, state) {
          return AsteriaPage(
            key: state.pageKey,
            name: state.name,
            child: Scaffold(body: Center(child: Text('Profile Payment'))),
          );
        },
      );

  static void go(BuildContext context) =>
      context.goNamed(ProfileRoutes.profilePaymentRouteName);

  static void push(BuildContext context) =>
      context.pushNamed(ProfileRoutes.profilePaymentRouteName);
}
