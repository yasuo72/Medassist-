// Daily health tips used in the HomeDashboard and potentially other parts of the app.
// Keeping them in their own file keeps the UI code clean and makes it easier to
// localise or expand this list later.

library daily_tips;

/// A curated list of more than 40 quick-read health tips.
/// These are intentionally short so they fit nicely in small UI spaces.
const List<String> kDailyHealthTips = [
  'Stay hydrated – drink at least 8 glasses of water today.',
  'Take a brisk 30-minute walk to boost cardiovascular health.',
  'Add a colourful fruit or veggie to each meal for extra vitamins.',
  'Do 10 deep-breath cycles now to reduce stress levels.',
  'Aim for at least 7 hours of sleep tonight for body recovery.',
  'Swap sugary drinks for water or unsweetened tea.',
  'Stretch your neck and shoulders for 2 minutes to ease tension.',
  'Choose whole-grain options for sustained energy.',
  'Wash your hands for 20 seconds before every meal.',
  'Take the stairs instead of the lift today.',
  'Practice 5 minutes of mindfulness or meditation.',
  'Include a source of lean protein in your lunch.',
  'Limit screen time 1 hour before bed for better sleep.',
  'Schedule your annual health check-up.',
  'Stand up and move for 2 minutes every hour.',
  'Replace salt with herbs and spices for flavour.',
  'Wear sunscreen if you’re going outside today.',
  'Check your posture: shoulders back, chin up.',
  'Snack on a handful of nuts instead of chips.',
  'Keep a reusable water bottle with you.',
  'Do 15 squats while waiting for the kettle to boil.',
  'Plan meals ahead to avoid unhealthy take-out.',
  'Take a power nap (10-20 min) if you feel drained.',
  'Practice gratitude by noting 3 things you’re thankful for.',
  'Add seeds (chia, flax) to your breakfast for omega-3s.',
  'Limit caffeinated drinks after 3 pm to improve sleep.',
  'Unplug from digital devices for 30 minutes and read a book.',
  'Include a rainbow of colours on your dinner plate.',
  'Do ankle rolls to improve joint mobility.',
  'Laugh out loud – it boosts immunity and mood.',
  'Replace one sugary snack with a piece of fruit today.',
  'Try a new healthy recipe this week.',
  'Keep your bedroom cool and dark for quality rest.',
  'Hold a plank for 30 seconds to strengthen your core.',
  'Chew food slowly to aid digestion.',
  'Take three deep breaths before responding when stressed.',
  'Set a reminder to check your blood pressure this month.',
  'Share a healthy meal photo to inspire others.',
  'Listen to upbeat music while exercising to stay motivated.',
  'Rinse canned beans to reduce sodium.',
  'Do wrist stretches if you type a lot.',
  'Swap fried foods for baked or grilled versions.',
  'End the day with light stretching for muscle recovery.',
  'Floss your teeth before bed for oral health.',
  'Plan tomorrow’s to-do list to clear your mind tonight.',
  'Spend 5 minutes outdoors to get natural light.',
];

/// Returns a tip based on the provided [date].
/// The same tip will be returned for everyone on the same day, but the
/// mapping is simple and deterministic.
String getTipForDate(DateTime date) {
  final int index = (date.day + date.month * 31) % kDailyHealthTips.length;
  return kDailyHealthTips[index];
}
