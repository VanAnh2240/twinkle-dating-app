import 'dart:io';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/home_controller.dart';
import 'package:twinkle/controllers/subscription/subscriptions_controller.dart';
import 'package:twinkle/pages/paywall_dialog_page.dart';
import 'package:twinkle/services/firestore_service.dart';
import 'package:twinkle/models/profile_model.dart';
import 'package:twinkle/themes/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AppinioSwiperController swiperController;
  final HomeController controller = Get.put(HomeController());
  final SubscriptionController subscriptionController = Get.find<SubscriptionController>();
  
  final RxBool _showActionButtons = true.obs;
  final RxInt dailySwipeCount = 0.obs;
  
  FirestoreService get _firestoreService => Get.find<FirestoreService>();

  @override
  void initState() {
    super.initState();
    swiperController = AppinioSwiperController();
    _loadDailySwipeCount();
  }

  @override
  void dispose() {
    swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadDailySwipeCount() async {
    dailySwipeCount.value = 0;
  }

  // Check if user can swipe
  Future<bool> canSwipe() async {
    if (subscriptionController.isPremium) {
      return true;
    }

    int availableCards;
    if (subscriptionController.isFree) {
      availableCards = 10;
    } else if (subscriptionController.isPlus) {
      availableCards = 50;
    } else {
      availableCards = 10; // Default to free
    }

    if (controller.currentIndex.value >= availableCards) {
      await PaywallDialog.showUnlimitedSwipes();
      return false;
    }

    return true;
  }
  
  // Handle swipe left
  Future<void> _handleSwipeLeft() async {
    if (!await canSwipe()) return;
    controller.swipeLeft();
    swiperController.swipeLeft();
  }

  // Handle swipe right
  Future<void> _handleSwipeRight() async {
    if (!await canSwipe()) return;
    controller.swipeRight();
    swiperController.swipeRight();
  }

  // Handle Super Like
  Future<void> _handleSuperLike() async {
    // Check if user has access to Super Like feature
    if (subscriptionController.isFree) {
      await PaywallDialog.showSuperLikes();
      return;
    }
    
    // Check Super Like limit
    final limit = subscriptionController.getSuperLikesLimit();
    
    if (!await canSwipe()) return;
    controller.swipeUp();
    swiperController.swipeUp();
    
    // Show success message
    Get.snackbar(
      'Super Like Sent! ⭐',
      'They\'ll know you really like them',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
                const SizedBox(height: 80),
              ],
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Twinkle',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 8),
              // Premium badge
              Obx(() {
                if (!subscriptionController.isPremium) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.diamond, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          
          Row(
            children: [
              // Swipe counter
              Obx(() {
                final limit = subscriptionController.getSwipeLimit();
                if (limit == -1) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple, width: 1),
                    ),
                  );
                }
                
                final remaining = limit - dailySwipeCount.value;
                final isLow = remaining <= 3;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLow 
                        ? Colors.red.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLow ? Colors.red : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: isLow ? Colors.red : Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$remaining/$limit',
                        style: TextStyle(
                          color: isLow ? Colors.red : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(width: 8),
              Obx(() => IconButton(
                onPressed: () => _showFilterDialog(),
                icon: Stack(
                  children: [
                    Icon(
                      Icons.tune,
                      color: controller.isFiltered.value ? Colors.blueAccent : Colors.white,
                    ),
                    if (controller.isFiltered.value)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refresh();
      },
      color: Colors.blueAccent,
      backgroundColor: Colors.white,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }

        if (controller.displayedUsers.isEmpty) {
          return _buildEmptyState();
        }

        if (controller.currentIndex.value >= controller.displayedUsers.length) {
          return _buildNoMorePeopleState();
        }

        return _buildSwiper();
      }),
    );
  }

  Widget _buildSwiper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppinioSwiper(
        controller: swiperController,
        cardCount: controller.displayedUsers.length,
        backgroundCardCount: 2,
        swipeOptions: const SwipeOptions.all(),
        loop: false,
        onSwipeEnd: (prevIndex, nextIndex, activity) {
          controller.currentIndex.value = nextIndex;
          if (nextIndex >= controller.displayedUsers.length) setState(() {});
        },
        onEnd: () => setState(() {}),
        cardBuilder: (context, index) {
          if (index >= controller.displayedUsers.length) return const SizedBox();
          return _ProfileCard(
            key: ValueKey('profile_card_$index'),
            user: controller.displayedUsers[index],
            index: index,
            totalCount: controller.displayedUsers.length,
            firestoreService: _firestoreService,
            controller: controller,
            swiperController: swiperController,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 80, color: Colors.white38),
              const SizedBox(height: 16),
              Obx(() => Text(
                    controller.isFiltered.value
                        ? 'No users match your filters'
                        : 'No users available',
                    style: const TextStyle(fontSize: 20, color: Colors.white70),
                  )),
              const SizedBox(height: 8),
              Obx(() => TextButton(
                    onPressed: () => controller.isFiltered.value
                        ? controller.resetFilters()
                        : controller.refresh(),
                    child: Text(
                        controller.isFiltered.value ? 'Reset Filters' : 'Refresh'),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoMorePeopleState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, size: 80, color: Colors.pinkAccent),
              const SizedBox(height: 26),
              const Text(
                'All matches explored',
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Time to let love catch up with you",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await controller.refresh();
                  dailySwipeCount.value = 0; // Reset count
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Page'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      if (controller.displayedUsers.isEmpty || 
          controller.currentIndex.value >= controller.displayedUsers.length) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionButton(
              icon: Icons.close,
              color: AppTheme.primaryColor,
              backgroundColor: const Color.fromARGB(255, 190, 189, 189),
              size: 56,
              onTap: _handleSwipeLeft,
            ),
            _actionButton(
              icon: Icons.star,
              color: Colors.white,
              backgroundColor: AppTheme.primaryColor, 
              size: 70,
              onTap: _handleSuperLike,
              showBadge: subscriptionController.isFree,
            ),
            _actionButton(
              icon: Icons.favorite,
              color: AppTheme.primaryColor,
              backgroundColor: Colors.white,
              size: 56,
              onTap: _handleSwipeRight,
            ),
          ],
        ),
      );
    });
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required double size,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: icon == Icons.star ? Colors.white : color,
              size: size * 0.5,
            ),
          ),
          // Premium badge for locked features
          if (showBadge)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  void _showFilterDialog() {
    controller.tempSelectedGender.value = controller.appliedGender.value;
    controller.tempMinAge.value = controller.appliedMinAge.value;
    controller.tempMaxAge.value = controller.appliedMaxAge.value;
    controller.tempSelectedInterests.value = List.from(controller.appliedInterests);
    controller.tempSelectedValues.value = List.from(controller.appliedValues);
    controller.tempMaxDistance.value = controller.appliedMaxDistance.value;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.grey[900],
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Obx(() {
                    if (!controller.isFiltered.value) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: AppTheme.secondaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Gender',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: '', label: Text('All')),
                      ButtonSegment(value: 'Man', label: Text('Man')),
                      ButtonSegment(value: 'Woman', label: Text('Woman')),
                    ],
                    selected: {controller.tempSelectedGender.value},
                    onSelectionChanged: (Set<String> newSelection) {
                      controller.updateTempGenderFilter(newSelection.first);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return AppTheme.secondaryColor;
                        }
                        return Colors.grey[800];
                      }),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Age Range',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Obx(() => Text(
                        '${controller.tempMinAge.value} - ${controller.tempMaxAge.value}',
                        style: const TextStyle(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              ),
              Obx(() => RangeSlider(
                    values: RangeValues(
                      controller.tempMinAge.value.toDouble(),
                      controller.tempMaxAge.value.toDouble(),
                    ),
                    min: 18,
                    max: 99,
                    divisions: 81,
                    activeColor: AppTheme.secondaryColor,
                    onChanged: (RangeValues values) {
                      controller.updateTempAgeFilter(
                        values.start.round(),
                        values.end.round(),
                      );
                    },
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.resetFilters();
                      Get.back();
                    },
                    child: const Text('Reset All'),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          controller.applyFilters();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatefulWidget {
  final dynamic user;
  final int index;
  final int totalCount;
  final FirestoreService firestoreService;
  final HomeController controller;
  final AppinioSwiperController swiperController;

  const _ProfileCard({
    Key? key,
    required this.user,
    required this.index,
    required this.totalCount,
    required this.firestoreService,
    required this.controller,
    required this.swiperController,
  }) : super(key: key);

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper method to get ImageProvider for any photo URL
  ImageProvider _getImageProvider(String photoUrl) {
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return NetworkImage(photoUrl);
    } else {
      return FileImage(File(photoUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final age = user.date_of_birth != null
        ? DateTime.now().difference(user.date_of_birth!).inDays ~/ 365
        : 0;

    return FutureBuilder<ProfileModel?>(
      future: widget.firestoreService.getUserProfile(user.user_id),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final photos = profile?.photos ?? [];
        final mainPhoto = photos.isNotEmpty ? photos[0] : user.profile_picture;
        final aboutMe = _parseAboutMe(profile);

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: Colors.black,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 500,
                        width: double.infinity,
                        decoration: mainPhoto.isNotEmpty
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: _getImageProvider(mainPhoto),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : BoxDecoration(
                                color: Colors.grey[800],
                              ),
                        child: mainPhoto.isEmpty
                            ? const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 100,
                                  color: Colors.white38,
                                ),
                              )
                            : null,
                      ),
                      
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.9),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (user.is_online) _onlineIndicator(),
                            const SizedBox(height: 8),
                            Text(
                              '${user.first_name}, $age',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    profile?.location ?? 'Location not set',
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '3 km away',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.index + 1}/${widget.totalCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      if (photos.length > 1)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 80,
                          child: Row(
                            children: List.generate(
                              photos.length > 6 ? 6 : photos.length,
                              (photoIndex) => Expanded(
                                child: Container(
                                  height: 3,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: photoIndex == 0
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Column(
                      children: const [
                        Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                        SizedBox(height: 4),
                        Text(
                          'Scroll down for more',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profile != null && profile.bio.isNotEmpty) ...[
                          _buildSection('My bio', profile.bio),
                          const SizedBox(height: 24),
                        ],
                        
                        if (aboutMe.isNotEmpty) ...[
                          _buildAboutMeSection(aboutMe),
                          const SizedBox(height: 24),
                        ],
                        
                        _buildSection(
                          "I'm looking for",
                          _getLookingForText(aboutMe),
                        ),
                        const SizedBox(height: 24),
                        
                        if (profile != null && profile.interests.isNotEmpty) ...[
                          _buildTagSection('My interests', profile.interests),
                          const SizedBox(height: 24),
                        ],
                        
                        if (photos.length > 1)
                          ...photos.sublist(1).map((photo) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: _getImageProvider(photo),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          )),
                        
                        if (profile != null && profile.communities.isNotEmpty) ...[
                          _buildTagSection('My Convictions', profile.communities),
                          const SizedBox(height: 24),
                        ],
                        
                        if (profile != null && profile.values.isNotEmpty) ...[
                          _buildTagSection('Personal Values', profile.values),
                          const SizedBox(height: 24),
                        ],
                        
                        _buildSwipeRightSection(aboutMe),
                        
                        const SizedBox(height: 32),
                        
                        _buildMatchAndBlockButtons(),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchAndBlockButtons() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            widget.controller.swipeRight();
            widget.swiperController.swipeRight();
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.favorite, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Match',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        InkWell(
          onTap: () => _showBlockConfirmDialog(),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(width: 8),
                Text(
                  'Block this person',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBlockConfirmDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF2A2A2A),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Block this person?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "This person won't be able to see or text\nyou again!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              InkWell(
                onTap: () {
                  Get.back();
                  widget.controller.blockCurrentUser();
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Block',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF9B59B6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTagSection(String title, List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF9B59B6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Text(
              tag,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAboutMeSection(Map<String, String> aboutMe) {
    final Map<String, String> emojiMap = {
      'Work': '📚',
      'Gender': '♂️',
      'Location': '📍',
      'Hometown': '🏠',
      'Height': '📏',
      'Exercise': '🏃',
      'Educational level': '🎓',
      'Drinking': '🍷',
      'Smoking': '🚬',
      'Religion': '☪️',
      'Family plans': '👶',
      'Star sign': '⭐',
    };

    List<String> tags = [];
    aboutMe.forEach((key, value) {
      if (value.isNotEmpty && key != 'Looking for') {
        final emoji = emojiMap[key] ?? '•';
        tags.add('$emoji $value');
      }
    });

    String aboutMeText = tags.isEmpty ? 'No info added yet' : tags.join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About me",
          style: TextStyle(
            color: Color(0xFF9B59B6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          aboutMeText,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSwipeRightSection(Map<String, String> aboutMe) {
    List<Widget> preferences = [];
    
    if (aboutMe['Smoking'] == 'Never') {
      preferences.add(
        Row(
          children: const [
            Icon(Icons.smoke_free, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'No smoking',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    if (aboutMe['Drinking'] == 'Never') {
      preferences.add(
        Row(
          children: const [
            Icon(Icons.no_drinks, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'No drinking',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    if (preferences.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Swipe right if you",
          style: TextStyle(
            color: Color(0xFF9B59B6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...preferences.map((pref) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: pref,
        )),
      ],
    );
  }

  Map<String, String> _parseAboutMe(ProfileModel? profile) {
    if (profile == null) return {};
    Map<String, String> aboutMe = {};
    for (var item in profile.about_me) {
      final parts = item.split(': ');
      if (parts.length >= 2) {
        aboutMe[parts[0]] = parts.sublist(1).join(': ');
      }
    }
    return aboutMe;
  }

  String _getLookingForText(Map<String, String> aboutMe) {
    if (aboutMe.containsKey('Looking for')) {
      return '✨ ${aboutMe['Looking for']}';
    }
    return 'Nothing to show';
  }

  Widget _onlineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircleAvatar(radius: 4, backgroundColor: Colors.white),
          SizedBox(width: 6),
          Text('Online', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}