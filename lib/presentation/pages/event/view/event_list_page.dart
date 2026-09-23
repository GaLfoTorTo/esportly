import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/pages/event/error/erro_event_page.dart';
import 'package:esportly/presentation/widget/cards/card_event_list_widget.dart';
import 'package:esportly/presentation/widget/bars/header_widget.dart';

class EventListPage extends ConsumerWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventSession = ref.watch(eventSessionProvider);

    return Scaffold(
      appBar: HeaderWidget(
        title: "Minhas Peladas",
        leftAction: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Builder(builder: (_) {
            if (eventSession.error) {
              return const ErroEventPage();
            }
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                spacing: 15,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                eventSession.events.map((event) {
                  return InkWell(
                    onTap: () {
                      ref.read(eventSessionProvider.notifier).setEvent(event);
                      context.go('/event/view');
                    },
                    child: CardEventListWidget(event: event)
                  );
                }).toList(),
              )
            );
          })
          
        ),
      ),
    );
  }
}
