import 'package:flutter/material.dart';

class KriyaTheme {
  static final KriyaTheme kriyaTheme = new KriyaTheme._internal();

  KriyaHomeTheme kriyaHomeTheme = KriyaHomeTheme();
  KriyaMyCourseListCard kriyaMyCourseListCard = KriyaMyCourseListCard();
  KriyaCourseSummary kriyaCourseSummary = KriyaCourseSummary();
  KriyaGeneralTheme kriyaGeneralTheme = KriyaGeneralTheme();
  KriyaColor kriyaColor = KriyaColor();

  factory KriyaTheme() {
    return kriyaTheme;
  }

  KriyaTheme._internal();
}

class KriyaColor {

  // Primary Color
  Color primaryColorOne   = Color(0xff2F8CB2);
  Color primaryColorTwo   = Color(0xff4C6880);
  Color primaryColorThree = Color(0xff049EDD);
  Color primaryColorFour  = Color(0xff6CCECB);

  // Kriya Lab
  Color kriyaLab109CD8 = Color(0xff109CD8);
  Color kriyaLab99E6FF = Color(0xff99E6FF);
  Color kriyaLabD02D91 = Color(0xffD02D91);
  Color kriyaLab63BCB9 = Color(0xff63BCB9);
  Color kriyaLabFFFFFF = Color(0xffffffff);
  Color kriyaLab2F8CB2 = Color(0xff2F8CB2);
  Color kriyaLabEB5757 = Color(0xffEB5757);

  // Grays
  Color grays484848 = Color(0xff484848);
  Color grays8B8B8B = Color(0xff8B8B8B);
  Color graysE5E5E5 = Color(0xffE5E5E5);
  Color grays6C6C6C = Color(0xff6C6C6C);
  Color graysBDBDBD = Color(0xffBDBDBD);
  Color graysE2E2E2 = Color(0xffE2E2E2);
  Color grays606161 = Color(0xff606161);
  Color graysF5F5F5 = Color(0xffF5F5F5);
  Color graysD0D0D0 = Color(0xffD0D0D0);
  Color graysECECEC = Color(0xffECECEC);
  Color graysF2F2F2 = Color(0xffF2F2F2);
  Color graysF4F4F4 = Color(0xffF4F4F4);
  Color graysF2F4F5 = Color(0xffF2F4F5);

  // Accent and System
  Color green82D96C   = Color(0xff82D96C);
  Color redF26253     = Color(0xffF26253);
  Color yellowFFB800  = Color(0xffFFB800);

  // Color with opacity
  Color black06 = Color.fromRGBO(0, 0, 0, 0.6);
  Color black025 = Color.fromRGBO(0, 0, 0, 0.25);
  Color gray005 = Color.fromRGBO(72, 72, 72, 0.05);
  Color gray063 = Color.fromRGBO(47, 47, 47, 0.63);
  Color gray142 = Color.fromRGBO(142, 142, 142, 0.25);
  Color gray245 = Color.fromRGBO(245, 245, 245, 0.25);

}

class KriyaGeneralTheme {

  var textInsideButtonWhite = TextStyle(
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontSize: 14.0,
    fontStyle: FontStyle.normal
  );

  var textInsideButtonBlue = TextStyle(
      fontWeight: FontWeight.w500,
      color: Color(0xff049EDD),
      fontSize: 14.0,
      fontStyle: FontStyle.normal
  );

}

class KriyaHomeTheme {
  // Home Kriya Features
  var kriyaHomeCardTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.white
  );

  var kriyaHomeCardSubtitle = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 11,
    color: Colors.white
  );

  var kriyaHomeCardLabGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      const Color.fromRGBO(72, 72, 72, 0),
      const Color.fromRGBO(16, 156, 216, 0.75)
    ],
  );

  var kriyaHomeCardSocialGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      const Color.fromRGBO(72, 72, 72, 0),
      const Color.fromRGBO(140, 107, 171, 0.75)
    ],
  );

  var kriyaHomeCardPulseGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      const Color.fromRGBO(72, 72, 72, 0),
      const Color.fromRGBO(247, 211, 93, 0.8)
    ],
  );

  BoxDecoration kriyaHomeCardTitleContainer(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(10.0)
  );
}

class KriyaMyCourseListCard {

  double containerHeight (BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return deviceHeight * 29 / 100;
  }

  double progressWidth (BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return deviceWidth * 75 / 100;
  }

  double progressCompletionWidth (BuildContext context, int completionLesson, int totalLesson) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double test = deviceWidth * 75 / 100;
    double test2 = (completionLesson / totalLesson) * test;
    return test2;
  }

  var kriyaMyCourseListCardLabGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      const Color.fromRGBO(120, 120, 120, 0),
      const Color.fromRGBO(0, 0, 0, 0)
    ],
  );

}

class KriyaCourseSummary {

  double collapsingToolbarHeight (BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return deviceHeight * 35.5 / 100;
  }

  double portraitImageHeight (BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return deviceHeight * 60 / 100;
  }

  // double expandedHeight (BuildContext context, Course course) {
  //   double deviceHeight = MediaQuery.of(context).size.height;
  //   if (course.userCourseId == null) {
  //     return deviceHeight * 82 / 100;
  //   } else {
  //     return deviceHeight * 90 / 100;
  //   }

  // }

}