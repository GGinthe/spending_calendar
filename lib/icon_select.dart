import 'package:flutter/material.dart';

Widget spendingIcon(String subject,Color iconColor, double iconSize) {
  if (subject == '其他') {
    return Icon(Icons.receipt_long, size: iconSize, color: iconColor,);
  } else if (subject == '早餐') {
    return Icon(Icons.breakfast_dining, size: iconSize, color: iconColor,);
  } else if (subject == '午餐') {
    return Icon(Icons.dinner_dining, size: iconSize, color: iconColor,);
  } else if (subject == '晚餐') {
    return Icon(Icons.ramen_dining, size: iconSize, color: iconColor,);
  } else if (subject == '飲品') {
    return Icon(Icons.wine_bar, size: iconSize, color: iconColor,);
  } else if (subject == '交通') {
    return Icon(Icons.train, size: iconSize, color: iconColor,);
  } else if (subject == '購物') {
    return Icon(Icons.shopping_bag, size: iconSize, color: iconColor,);
  } else if (subject == '房租') {
    return Icon(Icons.house, size: iconSize, color: iconColor,);
  } else if (subject == '社交') {
    return Icon(Icons.people, size: iconSize, color: iconColor,);
  }else if (subject == '點心') {
    return Icon(Icons.cake, size: iconSize, color: iconColor,);
  }else if (subject == '日用') {
    return Icon(Icons.local_grocery_store, size: iconSize, color: iconColor,);
  }else if (subject == '娛樂') {
    return Icon(Icons.games, size: iconSize, color: iconColor,);
  }else if (subject == '醫療') {
    return Icon(Icons.medical_services, size: iconSize, color: iconColor,);
  }else if (subject == '禮物') {
    return Icon(Icons.card_giftcard, size: iconSize, color: iconColor,);
  }else if (subject == '數位') {
    return Icon(Icons.phone_android, size: iconSize, color: iconColor,);
  }else if (subject == '學習') {
    return Icon(Icons.school, size: iconSize, color: iconColor,);
  }else if (subject == '保險') {
    return Icon(Icons.park, size: iconSize, color: iconColor,);
  }else if (subject == '薪水') {
    return Icon(Icons.currency_exchange, size: iconSize, color: iconColor,);
  }else if (subject == '股票') {
    return Icon(Icons.waterfall_chart, size: iconSize, color: iconColor,);
  }else if (subject == '回饋') {
    return Icon(Icons.money, size: iconSize, color: iconColor,);
  }else if (subject == '獎金') {
    return Icon(Icons.emoji_events, size: iconSize, color: iconColor,);
  }else if (subject == '租金') {
    return Icon(Icons.apartment, size: iconSize, color: iconColor,);
  }else if (subject == '投資') {
    return Icon(Icons.savings, size: iconSize, color: iconColor,);
  }else if (subject == '兼職') {
    return Icon(Icons.directions_run, size: iconSize, color: iconColor,);
  }else if (subject == '買賣') {
    return Icon(Icons.storefront, size: iconSize, color: iconColor,);
  }else if (subject == '餐飲') {
    return Icon(Icons.fastfood, size: iconSize, color: iconColor,);
  }else if (subject == '發票') {
    return Icon(Icons.receipt, size: iconSize, color: iconColor,);
  }
  return Icon(Icons.notes, size: iconSize, color: iconColor,);
}

Widget taskIcon(String subject) {
  if (subject == '工作') {
    return const Icon(Icons.work, size: 30);
  } else if (subject == '活動') {
    return const Icon(Icons.event, size: 30);
  } else if (subject == '提醒') {
    return const Icon(Icons.schedule, size: 30);
  } else if (subject == '其他') {
    return const Icon(Icons.bookmark, size: 30);
  }
  return const Icon(Icons.notes, size: 30);
}

Widget editTaskIcon(String subject, bool isSelected) {
  if (subject == '工作') {
    return Icon(
      Icons.work,
      size: 40,
      color: isSelected ? Colors.red : null,
    );
  } else if (subject == '活動') {
    return Icon(
      Icons.event,
      size: 40,
      color: isSelected ? Colors.red : null,
    );
  } else if (subject == '提醒') {
    return  Icon(
      Icons.schedule,
      size: 40,
      color: isSelected ? Colors.red : null,
    );
  } else if (subject == '其他') {
    return  Icon(
      Icons.bookmark,
      size: 40,
      color: isSelected ? Colors.red : null,
    );
  }
  return  Icon(
    Icons.notes,
    size: 40,
    color: isSelected ? Colors.red : null,
  );
}
