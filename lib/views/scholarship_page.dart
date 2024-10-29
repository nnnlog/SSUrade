import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade/components/common/key_value_data.dart';
import 'package:ssurade_application/port/in/viewmodel/scholarship_view_model_use_case.dart';
import 'package:ssurade_bloc/bloc/scholarship/scholarship_bloc.dart';

class ScholarshipPage extends StatefulWidget {
  const ScholarshipPage({super.key});

  @override
  State<StatefulWidget> createState() => _ScholarshipPage();
}

class _ScholarshipPage extends State<ScholarshipPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScholarshipBloc(scholarshipViewModelUseCase: context.read<ScholarshipViewModelUseCase>()),
      child: BlocSelector<ScholarshipBloc, ScholarshipState, bool>(selector: (state) {
        return state is ScholarshipShowing;
      }, builder: (context, showingState) {
        return Scaffold(
          appBar: customAppBar("장학 정보 조회"),
          backgroundColor: showingState ? const Color.fromRGBO(241, 242, 245, 1) : null,
          body: BlocBuilder<ScholarshipBloc, ScholarshipState>(builder: (context, state) {
            return switch (state) {
              ScholarshipInitial() => run(() {
                  context.read<ScholarshipBloc>().add(ScholarshipReady());
                  return Container();
                }),
              ScholarshipInitialLoading() => run(() {
                  context.read<ScholarshipBloc>().add(ScholarshipInformationRefreshRequested());
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LinearProgressIndicator(),
                          SizedBox(
                            width: 1,
                            height: 15,
                          ),
                          Text("장학 정보를 불러오고 있어요..."),
                        ],
                      ),
                    ),
                  );
                }),
              ScholarshipShowing() => BlocListener<ScholarshipBloc, ScholarshipState>(
                  listener: (context, state) {
                    if (state is ScholarshipShowing) {
                      _refreshController.refreshCompleted();
                    }
                  },
                  child: SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () {
                      context.read<ScholarshipBloc>().add(ScholarshipInformationRefreshRequested());
                    },
                    child: Container(
                      color: const Color.fromRGBO(241, 242, 245, 1),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: KeyValueTable(
                            map: Map.fromEntries(
                              [
                                    MapEntry(
                                        "총 수혜 금액",
                                        NumberFormat("###,###,###,###,###,###원")
                                            .format(state.scholarshipManager.data.map((e) => int.parse(e.price.replaceAll(",", ""))).reduce((value, element) => value + element))),
                                  ] +
                                  state.scholarshipManager.data
                                      .map(
                                        (e) => MapEntry("${e.name}\n(${e.when.displayText})", "${e.process}\n(${e.price}원)"),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            };
          }),
          floatingActionButton: showingState
              ? FloatingActionButton(
                  onPressed: () {
                    context.read<ScholarshipBloc>().add(ScholarshipInformationRefreshRequested());
                  },
                  child: const Icon(Icons.refresh),
                )
              : null,
        );
      }),
    );
  }
}
