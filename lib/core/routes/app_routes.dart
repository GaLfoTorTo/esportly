import 'package:esportly/presentation/pages/escalation/escalation_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:esportly/core/providers/app_session_provider.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/presentation/pages/app_base.dart';
import 'package:esportly/presentation/pages/home/home_base.dart';
import 'package:esportly/presentation/pages/notification/notification_page.dart';
import 'package:esportly/presentation/pages/splash_page.dart';
import 'package:esportly/presentation/pages/auth/login_page.dart';
import 'package:esportly/presentation/pages/register/onboarding_step.dart';
import 'package:esportly/presentation/pages/register/register_form.dart';
import 'package:esportly/presentation/pages/register/player_mode_step.dart';
import 'package:esportly/presentation/pages/register/manager_mode_step.dart';
import 'package:esportly/presentation/pages/onboarding/onboarding_page.dart';
import 'package:esportly/presentation/pages/profile/profile_page.dart';
import 'package:esportly/presentation/pages/chat/chats.dart';
import 'package:esportly/presentation/pages/chat/chat_private.dart';
import 'package:esportly/presentation/pages/escalation/escalation_landing_page.dart';
import 'package:esportly/presentation/pages/escalation/escalation_page.dart';
import 'package:esportly/presentation/pages/escalation/historic_page.dart';
import 'package:esportly/presentation/pages/escalation/market_page.dart';
import 'package:esportly/presentation/pages/escalation/statistics_page.dart';
import 'package:esportly/presentation/pages/games/detail/game_detail_page.dart';
import 'package:esportly/presentation/pages/event/view/event_day_page%20.dart';
import 'package:esportly/presentation/pages/games/config/game_config_page.dart';
import 'package:esportly/presentation/pages/games/config/game_random_teams_page.dart';
import 'package:esportly/presentation/pages/event/event_landing_page.dart';
import 'package:esportly/presentation/pages/event/view/event_list_page.dart';
import 'package:esportly/presentation/pages/event/view/event_page.dart';
import 'package:esportly/presentation/pages/event/view/event_settings_page.dart.dart';
import 'package:esportly/presentation/pages/event/view/event_historic_page.dart';
import 'package:esportly/presentation/pages/event/register/event_config_game_step.dart';
import 'package:esportly/presentation/pages/event/register/event_basic_step.dart';
import 'package:esportly/presentation/pages/event/register/event_address_step.dart';
import 'package:esportly/presentation/pages/event/register/event_participants_step.dart';
import 'package:esportly/presentation/pages/explore/explore_landing_page.dart';
import 'package:esportly/presentation/pages/explore/map/map_picker.dart';
import 'package:esportly/presentation/pages/explore/map/map_explorer.dart';
import 'package:esportly/presentation/pages/explore/explore_filter_page.dart';
import 'package:esportly/presentation/pages/explore/explore_search_page.dart';

class _SessionRefreshNotifier extends ChangeNotifier {
  _SessionRefreshNotifier(ProviderContainer container) {
    container.listen(appSessionProvider, (_, __) => notifyListeners());
  }
}

class AppRoutes {
  static GoRouter createRouter(ProviderContainer container) {
    final refreshNotifier = _SessionRefreshNotifier(container);
    return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session = container.read(appSessionProvider);
      final location = state.matchedLocation;
      switch (session) {
        case AppSession.loading:
          return location == '/splash' ? null : '/splash';
        case AppSession.unauthenticated:
          return (location == '/login' || location.startsWith('/register')) ? null : '/login';
        case AppSession.firstLogin:
          return location == '/onboarding' ? null : '/onboarding';
        case AppSession.authenticated:
          return (location == '/splash' || location == '/login') ? '/home' : null;
      }
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (_, __) => const NoTransitionPage(child: SplashPage()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, __) => transitionToRight(const LoginPage()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, __) => transitionToLeft(const OnboardingPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppBase(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(index),
          child: navigationShell,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (_, __) => NoTransitionPage(child: HomeBase()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/escalation',
              pageBuilder: (_, __) => const NoTransitionPage(child: EscalationLandingPage()),
              routes: [
                GoRoute(
                  path: 'list',
                  pageBuilder: (_, __) => transitionToLeft(const EscalationListPage()),
                ),
                GoRoute(
                  path: 'team',
                  pageBuilder: (_, __) => transitionToLeft(const EscalationPage()),
                ),
                GoRoute(
                  path: 'statistics',
                  pageBuilder: (_, __) => transitionToLeft(const StatisticsPage()),
                ),
                GoRoute(
                  path: 'market',
                  pageBuilder: (_, __) => transitionToLeft(const MarketPage()),
                ),
                GoRoute(
                  path: 'historic',
                  pageBuilder: (_, __) => transitionToLeft(const HistoricPage()),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/event',
              pageBuilder: (_, __) => const NoTransitionPage(child: EventLandingPage()),
              routes: [
                GoRoute(
                  path: '/day',
                  pageBuilder: (_, __) => const NoTransitionPage(child: EventDayPage()),
                ),
                GoRoute(
                  path: 'view',
                  pageBuilder: (_, __) => transitionToLeft(const EventPage()),
                  routes: [
                    GoRoute(
                      path: 'settings',
                      pageBuilder: (_, __) => transitionToLeft(const EventSettingsPage()),
                    ),
                    GoRoute(
                      path: 'historic',
                      pageBuilder: (_, __) => transitionToLeft(const EventHistoricPage()),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'list',
                  pageBuilder: (_, __) => transitionToLeft(const EventListPage()),
                ),
                GoRoute(
                  path: 'register',
                  redirect: (_, __) => '/event/register/basic',
                  routes: [
                    GoRoute(
                      path: 'basic',
                      pageBuilder: (_, __) => transitionToLeft(const EventBasicStep()),
                    ),
                    GoRoute(
                      path: 'address',
                      pageBuilder: (_, __) => transitionToLeft(const EventAddressStep()),
                    ),
                    GoRoute(
                      path: 'config_games',
                      pageBuilder: (_, __) => transitionToLeft(const EventConfigGameStep()),
                    ),
                    GoRoute(
                      path: 'participants',
                      pageBuilder: (_, __) => transitionToLeft(const EventParticipantsStep()),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/explore',
              pageBuilder: (_, __) => const NoTransitionPage(child: ExploreLandingPage()),
              routes: [
                GoRoute(
                  path: 'map',
                  pageBuilder: (_, __) => transitionToLeft(const MapExplorePage()),
                ),
                GoRoute(
                  path: 'picker',
                  pageBuilder: (_, __) => transitionToLeft(const MapPickerPage()),
                ),
                GoRoute(
                  path: 'search',
                  pageBuilder: (_, __) => transitionToLeft(const ExploreSearchPage()),
                ),
                GoRoute(
                  path: 'filter',
                  pageBuilder: (_, __) => transitionToLeft(const ExploreFilterPage()),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/notifications',
              pageBuilder: (_, __) => const NoTransitionPage(child: NotificationPage()),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (_, __) => transitionToLeft(const ProfilePage()),
      ),
      GoRoute(
        path: '/chats',
        pageBuilder: (_, __) => transitionToLeft(const ChatsPage()),
        routes: [
          GoRoute(
            path: '/private',
            pageBuilder: (context, state) => transitionToLeft(ChatPrivatePage(user: state.extra as UserModel)),
          ),
        ]
      ),
      GoRoute(
        path: '/register',
        redirect: (_, __) => '/register/onboarding',
        routes: [
          GoRoute(
            path: 'onboarding',
            pageBuilder: (_, __) => transitionToRight(const OnboardingStep()),
          ),
          GoRoute(
            path: 'dados_basicos',
            pageBuilder: (_, __) => transitionToLeft(const RegisterStep()),
          ),
          GoRoute(
            path: 'player',
            pageBuilder: (_, __) => transitionToRight(const PlayerModeStep()),
          ),
          GoRoute(
            path: 'manager',
            pageBuilder: (_, __) => transitionToRight(const ManagerModeStep()),
          ),
        ],
      ),
      GoRoute(
        path: '/games',
        redirect: (_, __) => '/games/overview',
        routes: [
          GoRoute(
            path: '/config',
            pageBuilder: (_, __) => const NoTransitionPage(child: GameConfigPage()),
          ),
          GoRoute(
            path: '/teams',
            pageBuilder: (_, __) => const NoTransitionPage(child: GameRandomTeamsPage()),
          ),
          GoRoute(
            path: '/overview',
            pageBuilder: (_, __) => const NoTransitionPage(child: GameDetailPage()),
          ),
        ],
      ),
    ],
  ); // GoRouter
  } // createRouter

  static CustomTransitionPage transitionToLeft(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage transitionToRight(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
          child: child,
        );
      },
    );
  }
}
