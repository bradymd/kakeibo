import 'package:flutter/material.dart';

enum Pillar {
  needs,
  wants,
  culture,
  unexpected;

  String get label {
    switch (this) {
      case Pillar.needs:
        return 'Needs';
      case Pillar.wants:
        return 'Wants';
      case Pillar.culture:
        return 'Culture';
      case Pillar.unexpected:
        return 'Unexpected';
    }
  }

  String get japanese {
    switch (this) {
      case Pillar.needs:
        return '必要';
      case Pillar.wants:
        return '欲しい';
      case Pillar.culture:
        return '文化';
      case Pillar.unexpected:
        return '予想外';
    }
  }

  String get description {
    switch (this) {
      case Pillar.needs:
        return 'Essentials: groceries, transport, household';
      case Pillar.wants:
        return 'Nice-to-haves: dining out, hobbies, entertainment';
      case Pillar.culture:
        return 'Self-improvement: books, courses, museums';
      case Pillar.unexpected:
        return 'Surprises: repairs, medical, gifts';
    }
  }

  IconData get icon {
    switch (this) {
      case Pillar.needs:
        return Icons.home_rounded;
      case Pillar.wants:
        return Icons.card_giftcard_rounded;
      case Pillar.culture:
        return Icons.auto_awesome_rounded;
      case Pillar.unexpected:
        return Icons.bolt_rounded;
    }
  }

  Color get color {
    switch (this) {
      case Pillar.needs:
        return const Color(0xFF64748B); // slate
      case Pillar.wants:
        return const Color(0xFFEC4899); // pink
      case Pillar.culture:
        return const Color(0xFF9333EA); // purple
      case Pillar.unexpected:
        return const Color(0xFFF97316); // orange
    }
  }

  Color get backgroundColor {
    switch (this) {
      case Pillar.needs:
        return const Color(0xFFF1F5F9);
      case Pillar.wants:
        return const Color(0xFFFCE7F3);
      case Pillar.culture:
        return const Color(0xFFF3E8FF);
      case Pillar.unexpected:
        return const Color(0xFFFFF7ED);
    }
  }
}
