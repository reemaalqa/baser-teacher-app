import 'package:eschool_teacher/cubits/chat/chatUsersCubit.dart';
import 'package:eschool_teacher/ui/screens/chat/widget/charUserItem.dart';
import 'package:eschool_teacher/ui/styles/colors.dart';
import 'package:eschool_teacher/ui/widgets/appBarTitleContainer.dart';
import 'package:eschool_teacher/ui/widgets/customBackButton.dart';
import 'package:eschool_teacher/ui/widgets/customShimmerContainer.dart';
import 'package:eschool_teacher/ui/widgets/customTabBarContainer.dart';
import 'package:eschool_teacher/ui/widgets/errorContainer.dart';
import 'package:eschool_teacher/ui/widgets/loadMoreErrorWidget.dart';
import 'package:eschool_teacher/ui/widgets/noDataContainer.dart';
import 'package:eschool_teacher/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool_teacher/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool_teacher/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:eschool_teacher/utils/animationConfiguration.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatUsersScreen extends StatefulWidget {
  const ChatUsersScreen({
    super.key,
  });

  static route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const ChatUsersScreen(),
    );
  }

  @override
  State<ChatUsersScreen> createState() => _ChatUsersScreenState();
}

class _ChatUsersScreenState extends State<ChatUsersScreen> {
  final PageController _pageController = PageController();
  late String _selectedTabTitle = studentsKey;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_notificationsScrollListener);

  void _notificationsScrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      late final ChatUsersCubit cubit;
      if (_selectedTabTitle == parentsKey) {
        cubit = context.read<ParentChatUserCubit>();
      } else {
        cubit = context.read<StudentChatUsersCubit>();
      }
      if (cubit.hasMore()) {
        cubit.fetchMoreChatUsers();
      }
    }
  }

  _buildUnreadCounter({required int count}) {
    return count == 0
        ? const SizedBox.shrink()
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: greenColor.withOpacity(.8),
            ),
            margin: const EdgeInsetsDirectional.only(start: 5),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              (count > 999) ? "999+" : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          );
  }

  @override
  void initState() {
    super.initState();
    fetchChatUsers();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_notificationsScrollListener);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void fetchChatUsers() {
    if (_selectedTabTitle == parentsKey) {
      context.read<ParentChatUserCubit>().fetchChatUsers();
    } else {
      context.read<StudentChatUsersCubit>().fetchChatUsers();
    }
  }

  Widget _buildAppBar(
    BuildContext context,
  ) {
    return ScreenTopBackgroundContainer(
      heightPercentage: UiUtils.appBarBiggerHeightPercentage,
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const CustomBackButton(),
            AppBarTitleContainer(
              boxConstraints: boxConstraints,
              title: UiUtils.getTranslatedLabel(context, chatKey),
            ),
            AnimatedAlign(
              curve: UiUtils.tabBackgroundContainerAnimationCurve,
              duration: UiUtils.tabBackgroundContainerAnimationDuration,
              alignment: _selectedTabTitle == studentsKey
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              child: TabBackgroundContainer(boxConstraints: boxConstraints),
            ),
            CustomTabBarContainer(
              boxConstraints: boxConstraints,
              alignment: AlignmentDirectional.centerStart,
              isSelected: _selectedTabTitle == studentsKey,
              onTap: () {
                if (_selectedTabTitle != studentsKey) {
                  _pageController.jumpToPage(0);
                  setState(() {
                    _selectedTabTitle = studentsKey;
                  });
                }
              },
              customPostFix: BlocBuilder<StudentChatUsersCubit, ChatUsersState>(
                builder: (context, state) {
                  return (state is ChatUsersFetchSuccess)
                      ? _buildUnreadCounter(count: state.totalUnreadUsers)
                      : const SizedBox.shrink();
                },
              ),
              titleKey: studentsKey,
            ),
            CustomTabBarContainer(
              boxConstraints: boxConstraints,
              alignment: AlignmentDirectional.centerEnd,
              isSelected: _selectedTabTitle == parentsKey,
              onTap: () {
                if (_selectedTabTitle != parentsKey) {
                  _pageController.jumpToPage(1);
                  setState(() {
                    _selectedTabTitle = parentsKey;
                  });
                }
              },
              customPostFix: BlocBuilder<ParentChatUserCubit, ChatUsersState>(
                builder: (context, state) {
                  return (state is ChatUsersFetchSuccess)
                      ? _buildUnreadCounter(count: state.totalUnreadUsers)
                      : const SizedBox.shrink();
                },
              ),
              titleKey: parentsKey,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShimmerLoader() {
    return ShimmerLoadingContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return SizedBox(
            height: double.maxFinite,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: UiUtils.defaultShimmerLoadingContentCount,
              itemBuilder: (context, index) {
                return _buildOneChatUserShimmerLoader();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOneChatUserShimmerLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: MediaQuery.of(context).size.width * (0.075),
      ),
      child: const ShimmerLoadingContainer(
        child: CustomShimmerContainer(
          height: 80,
          borderRadius: 12,
        ),
      ),
    );
  }

  Widget _stateItemsBuilder(
      {required BuildContext context,
      required ChatUsersState state,
      required ChatUsersCubit chatUsersCubit}) {
    if (state is ChatUsersFetchSuccess) {
      return state.chatUsers.isEmpty
          ? const NoDataContainer(
              titleKey: noChatUsersKey,
            )
          : Padding(
              padding: EdgeInsetsDirectional.only(
                top: UiUtils.getScrollViewTopPadding(
                  context: context,
                  keepExtraSpace: false,
                  appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
                ),
              ),
              child: SizedBox(
                height: double.maxFinite,
                width: double.maxFinite,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ...List.generate(
                        state.chatUsers.length,
                        (index) {
                          final currentChatUser = state.chatUsers[index];
                          return Animate(
                            effects: customItemFadeAppearanceEffects(),
                            child: ChatUserItemWidget(
                              chatUser: currentChatUser,
                            ),
                          );
                        },
                      ),
                      if (state.moreChatUserFetchProgress)
                        _buildOneChatUserShimmerLoader(),
                      if (state.moreChatUserFetchError &&
                          !state.moreChatUserFetchProgress)
                        LoadMoreErrorWidget(
                          onTapRetry: () {
                            chatUsersCubit.fetchMoreChatUsers();
                          },
                        ),
                      SizedBox(
                        height: UiUtils.getScrollViewBottomPadding(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
    }
    if (state is ChatUsersFetchFailure) {
      return Center(
        child: ErrorContainer(
          errorMessageCode: state.errorMessage,
          onTapRetry: () {
            fetchChatUsers();
          },
        ),
      );
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: UiUtils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
        ),
      ),
      child: _buildShimmerLoader(),
    );
  }

  Widget _buildParentChatUsers({required BuildContext context}) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        if (index == 0) {
          _selectedTabTitle = studentsKey;
        } else {
          _selectedTabTitle = parentsKey;
        }
        setState(() {});
      },
      children: [
        BlocBuilder<StudentChatUsersCubit, ChatUsersState>(
          builder: (context, state) {
            return _stateItemsBuilder(
                context: context,
                state: state,
                chatUsersCubit: context.read<StudentChatUsersCubit>());
          },
        ),
        BlocBuilder<ParentChatUserCubit, ChatUsersState>(
          builder: (context, state) {
            return _stateItemsBuilder(
                context: context,
                state: state,
                chatUsersCubit: context.read<ParentChatUserCubit>());
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildParentChatUsers(context: context),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(context),
          ),
        ],
      ),
    );
  }
}
