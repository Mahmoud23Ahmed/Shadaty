import 'package:flutter/material.dart';
import 'package:luckywheel/Screens/login.dart';
import 'package:luckywheel/Screens/user/mainscreen.dart';

void main() {
  runApp(const PrivacyScreen());
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Container(
              width: double.infinity,
              height: 80,
              color: Colors.white,
              child: const Center(
                child: Text(
                  'سياسة الخصوصية',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      Text(
                        'جمع البيانات الشخصية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'يقوم هذا التطبيق بجمع المعلومات من مستخدميه عند تسجيلهم للوصول إلى خدماتنا أو في حالات أخرى محددة عندما يطلب منهم تزويدنا بمعلوماتهم الشخصية، وهذه المعلومات يتم جمعها بالوسائل التالية:\n- معلومات من حسابك اسمك ورقم الجوال والبلد و تاریخ الميلاد.\n- معلومات من نشاطك تتضمن هذه المعلومات عناوين بروتوكول الإنترنت IP المستخدم لربط جهازك الخاص بشبكة الإنترنت واسم وموقع الجهاز، ونوع نظام التشغيل، ومعلومات شبكة المحمول بما في ذلك رقم الجوال ومعرفات الجهاز، والإصدار وتفضيلات اللغة وأوقات الوصول والتواريخ والإحصاءات الأخرى.\n- معلومات من ملفات تعريف الارتباط نقوم بجمع المعلومات من خلال ملفات تعريف الارتباط المخزنة بواسطة مواقع الويب على محرك الأقراص الثابت الخاص بك.\n- معلومات زودتنا بها : قد تقدم لنا طوعاً معلومات إضافية عن نفسك لا تحدد هويتك الشخصية، بما في ذلك، على سبيل المثال الاسم البلد، وتفضيلات الخدمة، ونوع الهاتف الذكي ومعلومات تقنية عن أساليب اتصال المستخدم بالتطبيق، وغيرها من المعلومات المشابهة التي زودتنا بها من خلال ملء النماذج المتوفرة على منصتنا أو من خلال التواصل معنا عبر الهاتف، أو أي وسيلة أخرى. لذا يتوجب عليك الالتزام بتقديم معلومات كاملة وصحيحة ودقيقة والالتزام بالحفاظ على سرية معلومات حسابك وتحديد الأشخاص المسموح لهم بالوصول إلى حسابك واستخدامه. وإلا ستكون مسئولاً عن أي أضرار تنتج عن عدم دقة هذه المعلومات والبيانات أو عدم تحديثها بمجرد تغييرها. ويجوز لنا مشاركة المعلومات المذكورة مع أطراف ثالثة لغرض تصميم الإعلانات وتحليلها وإدارتها وتقديم التقارير وتحسينها على التطبيق وغيرها.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF78909C),
                        ),
                      ),
                      // ... rest of the text views
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 50,
              color: const Color(0xFFBF360C),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFBF360C),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainScreen()),
                      );
                    },
                    child: const Text(
                      'الموافقة على سياسة الخصوصية ',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 50,
              color: const Color(0x00ff5722),
              child: const Center(
                child: Text(
                  'متابعة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
