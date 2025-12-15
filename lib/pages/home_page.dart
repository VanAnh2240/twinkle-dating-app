import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AppinioSwiperController swiperController;
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    swiperController = AppinioSwiperController();
  }

  @override
  void dispose() {
    swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
            _buildActionButtons(),
            const SizedBox(height: 16),
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
          const Text(
            'Twinkle',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.tune, color: Colors.white),
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
          return _buildProfileCard(index);
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
                    child: Obx(() => Text(
                        controller.isFiltered.value ? 'Reset Filters' : 'Refresh')),
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

  Widget _buildProfileCard(int index) {
    final user = controller.displayedUsers[index];
    final age = user.date_of_birth != null
        ? DateTime.now().difference(user.date_of_birth!).inDays ~/ 365
        : 0;

    return GestureDetector(
      onTap: () => controller.viewUserProfile(user),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            user.profile_picture.isNotEmpty
                ? Image.network(user.profile_picture, fit: BoxFit.cover)
                : Container(color: Colors.grey[800], child: const Icon(Icons.person, size: 100, color: Colors.white38)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
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
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Tap to view profile',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
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
                  '${index + 1}/${controller.displayedUsers.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onlineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
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

  Widget _buildActionButtons() {
    return Obx(() {
      if (controller.displayedUsers.isEmpty || controller.currentIndex.value >= controller.displayedUsers.length) {
        return const SizedBox.shrink();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(icon: Icons.close, color: Colors.red, onTap: () {
            controller.swipeLeft();
            swiperController.swipeLeft();
          }),
          _actionButton(icon: Icons.star, color: Colors.yellow, onTap: () {
            controller.swipeUp();
            swiperController.swipeUp();
          }),
          _actionButton(icon: Icons.favorite, color: Colors.green, onTap: () {
            controller.swipeRight();
            swiperController.swipeRight();
          }),
        ],
      );
    });
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10, spreadRadius: 1)],
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }

   void _showFilterDialog() {
    // Copy temp values
    controller.tempSelectedGender.value = controller.appliedGender.value;
    controller.tempMinAge.value = controller.appliedMinAge.value;
    controller.tempMaxAge.value = controller.appliedMaxAge.value;
    controller.tempSelectedInterests.value = List.from(controller.appliedInterests);
    controller.tempSelectedValues.value = List.from(controller.appliedValues);
    controller.tempMaxDistance.value = controller.appliedMaxDistance.value;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Obx(() {
                    if (!controller.isFiltered.value) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Active', style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'all', label: Text('All')),
                      ButtonSegment(value: 'male', label: Text('Male')),
                      ButtonSegment(value: 'female', label: Text('Female')),
                    ],
                    selected: {controller.tempSelectedGender.value},
                    onSelectionChanged: (Set<String> newSelection) {
                      controller.updateTempGenderFilter(newSelection.first);
                    },
                  )),
              const SizedBox(height: 16),
              const Text('Age Range', style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => RangeSlider(
                    values: RangeValues(controller.tempMinAge.value.toDouble(), controller.tempMaxAge.value.toDouble()),
                    min: 18,
                    max: 99,
                    divisions: 81,
                    labels: RangeLabels(controller.tempMinAge.value.toString(), controller.tempMaxAge.value.toString()),
                    onChanged: (RangeValues values) {
                      controller.updateTempAgeFilter(values.start.round(), values.end.round());
                    },
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () {
                    controller.resetFilters();
                    if (mounted) Get.back();
                  }, child: const Text('Reset All')),
                  Row(
                    children: [
                      TextButton(onPressed: () { if (mounted) Get.back(); }, child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: () {
                        controller.applyFilters();
                        if (mounted) Get.back();
                      }, child: const Text('Apply')),
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
