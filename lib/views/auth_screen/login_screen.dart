import '../../const/const.dart';
import '../../controller/auth_controller.dart';
import '../home_screen/home.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/our_button.dart';
import '../widgets/test_style.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var controller = Get.put(AuthController());
  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: purpleColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              30.heightBox,
              30.heightBox,
              Row(
                children: [
                  Image.asset(icLogo, width: 70, height: 70)
                      .box
                      .border(color: white)
                      .rounded
                      .padding(const EdgeInsets.all(8.0))
                      .make(),
                  20.widthBox,
                  boldText(text: appname, size: 20.0)
                ],
              ),
              40.heightBox,
              normalText(text: loginTo, size: 18.0, color: lightGrey),
              10.heightBox,
              Obx(
                () => SizedBox(
                        child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controller.emailController,
                        decoration: const InputDecoration(
                            filled: true,
                            fillColor: textfieldGrey,
                            labelText: email,
                            prefixIcon: Icon(Icons.email, color: purpleColor),
                            border: InputBorder.none,
                            hintText: emailHint),
                      ),
                      10.heightBox,
                      TextFormField(
                        obscureText: !isPasswordVisible,
                        controller: controller.passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: textfieldGrey,
                          labelText: password,
                          prefixIcon: const Icon(Icons.lock, color: purpleColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: purpleColor,
                            ),
                            onPressed: togglePasswordVisibility,
                          ),
                          border: InputBorder.none,
                          hintText: passwordHint,
                        ),
                      ),
                      20.heightBox,
                      SizedBox(
                        width: context.screenWidth - 100,
                        child: controller.isLoading.value
                            ? loadingIndicator()
                            : ourButton(
                                title: login,
                                onPress: () async {
                                  controller.isLoading(true);
                                  await controller
                                      .loginMethod(context: context)
                                      .then((value) {
                                    if (value != null) {
                                      VxToast.show(context, msg: "Connecté");
                                      controller.isLoading(false);
                                      controller.clearfield();
                                      Get.off(() => const Home());
                                    } else {
                                      controller.isLoading(false);
                                    }
                                  });
                                },
                              ),
                      ),
                    ],
                  ),
                ))
                    .box
                    .color(white.withOpacity(0.2))
                    .rounded
                    .outerShadow
                    .padding(const EdgeInsets.all(8))
                    .make(),
              ),
              10.heightBox,
              20.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}
