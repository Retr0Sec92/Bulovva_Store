import 'package:firebase_auth/firebase_auth.dart';
import 'package:papape_store/Components/gradient_button.dart';
import 'package:papape_store/Components/progress.dart';
import 'package:papape_store/Components/wrapper.dart';
import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Services/authentication_service.dart';
import 'package:papape_store/Services/toast_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Sign extends StatefulWidget {
  const Sign({Key key}) : super(key: key);

  @override
  _SignState createState() => _SignState();
}

class _SignState extends State<Sign> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordVerifyController =
      TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isVisible = false;
  bool loginWithPhone = false;
  bool codeSent = false;
  String verificationCode;

  void verifyCode() async {
    setState(() {
      isLoading = true;
    });
    if (codeController.text.isNotEmpty) {
      if (verificationCode.isNotEmpty) {
        context
            .read<AuthService>()
            .verifyCodeAndSaveUser(
                name: nameController.text.trim(),
                code: codeController.text.trim(),
                verification: verificationCode)
            .then((value) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthWrapper()));
            })
            .onError(
                (error, stackTrace) => ToastService().showError(error, context))
            .whenComplete(() => setState(() {
                  isLoading = false;
                }));
      } else {
        ToastService()
            .showWarning('Telefonunuza tekrar kod istemelisiniz!', context);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ToastService().showWarning('Doğrulama kodu boş olamaz!', context);
      setState(() {
        isLoading = false;
      });
    }
  }

  void verifyPhone() async {
    setState(() {
      isLoading = true;
    });
    if (formkey.currentState.validate()) {
      FirebaseAuth firebaseAuth = context.read<AuthService>().getInstance();
      await firebaseAuth
          .verifyPhoneNumber(
              phoneNumber: '+90${phoneController.text.trim()}',
              verificationCompleted: (PhoneAuthCredential credential) async {
                setState(() {
                  isLoading = false;
                });
              },
              verificationFailed: (FirebaseAuthException exception) {
                setState(() {
                  isLoading = false;
                });
                if (exception.code == 'too-many-requests') {
                  ToastService().showError(
                      'İşleminiz, çok fazla denemeniz doğrultusunda engellendi tekrar deneyebilmek için lütfen bekleyiniz yada diğer giriş yöntemlerini deneyebilirsiniz.',
                      context);
                } else {
                  ToastService().showError(
                      'SMS gönderilmesi sırasında bir hata oluştu! Girdiğiniz telefon numarasını kontrol edebilir yada diğer giriş yöntemlerini deneyebilirsiniz.',
                      context);
                }
              },
              codeSent: (String verificationId, [int forceResendingToken]) {
                setState(() {
                  isLoading = false;
                  verificationCode = verificationId;
                  codeSent = true;
                });
              },
              codeAutoRetrievalTimeout: (String verificationId) {})
          .timeout(const Duration(seconds: 60));
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void signUp() {
    if (passwordController.text != passwordVerifyController.text) {
      ToastService().showError(
          'Girdiğiniz şifreler eşleşmemektedir ! Lütfen girdiğiniz şifreleri tekrar kontrol ediniz.',
          context);
      return;
    }
    if (formkey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      context
          .read<AuthService>()
          .signUp(
              name: nameController.text.trim(),
              email: emailController.text.trim(),
              password: passwordController.text.trim())
          .then((value) {
            CoolAlert.show(
                context: context,
                type: CoolAlertType.warning,
                title: '',
                text: value,
                showCancelBtn: false,
                backgroundColor: ColorConstants.instance.primaryColor,
                confirmBtnColor: ColorConstants.instance.primaryColor,
                onConfirmBtnTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                barrierDismissible: false,
                confirmBtnText: 'Evet');
          })
          .onError(
              (error, stackTrace) => ToastService().showError(error, context))
          .whenComplete(() => setState(() {
                isLoading = false;
              }));
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String validateMail(value) {
    if (value.isEmpty) {
      return "* E-mail zorunludur !";
    } else {
      return null;
    }
  }

  String validatePass(value) {
    if (value.isEmpty) {
      return "* Şifre zorunludur !";
    } else {
      return null;
    }
  }

  String validatePassAgain(value) {
    if (value.isEmpty) {
      return "* Şifre(Tekrar) zorunludur !";
    } else {
      return null;
    }
  }

  String validateName(value) {
    if (value.isEmpty) {
      return "* İsim-Soyisim zorunludur !";
    } else {
      return null;
    }
  }

  String validatePhone(value) {
    if (value.isEmpty) {
      return "* Telefon Numarası zorunludur !";
    } else {
      return null;
    }
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: ColorConstants.instance.primaryColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorConstants.instance.whiteContainer,
          iconTheme: IconThemeData(color: ColorConstants.instance.primaryColor),
          elevation: 0,
        ),
        body: (isLoading == false)
            ? SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: ColorConstants.instance.whiteContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 30.0, left: 30.0, bottom: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/login_logo.png',
                            height: MediaQuery.of(context).size.height / 5),
                        Visibility(
                          visible: !codeSent,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: TextFormField(
                                controller: nameController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.account_circle_outlined),
                                    labelText: 'İsim-Soyisim'),
                                validator: validateName),
                          ),
                        ),
                        Visibility(
                          visible: loginWithPhone && !codeSent,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                decoration: const InputDecoration(
                                    prefix: Text('+90'),
                                    icon: Icon(Icons.phone),
                                    labelText: 'Telefon Numarası'),
                                validator: validatePhone),
                          ),
                        ),
                        Visibility(
                          visible: codeSent,
                          child: PinPut(
                            fieldsCount: 6,
                            controller: codeController,
                            submittedFieldDecoration:
                                _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            selectedFieldDecoration: _pinPutDecoration,
                            followingFieldDecoration:
                                _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: ColorConstants.instance.textGold,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !loginWithPhone,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.mail),
                                    labelText: 'E-Posta'),
                                validator: validateMail),
                          ),
                        ),
                        Visibility(
                          visible: !loginWithPhone,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: TextFormField(
                              obscureText: (isVisible == false) ? true : false,
                              controller: passwordController,
                              decoration: InputDecoration(
                                  icon: const Icon(Icons.vpn_key_outlined),
                                  labelText: 'Yeni Parola',
                                  suffixIcon: IconButton(
                                    icon: (isVisible == false)
                                        ? const Icon(Icons.visibility_off)
                                        : const Icon(Icons.visibility),
                                    onPressed: () {
                                      if (isVisible == true) {
                                        setState(() {
                                          isVisible = false;
                                        });
                                      } else {
                                        setState(() {
                                          isVisible = true;
                                        });
                                      }
                                    },
                                  )),
                              validator: validatePass,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !loginWithPhone,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: TextFormField(
                              obscureText: (isVisible == false) ? true : false,
                              controller: passwordVerifyController,
                              decoration: InputDecoration(
                                  icon: const Icon(Icons.vpn_key_outlined),
                                  labelText: 'Yeni Parola (Tekrar)',
                                  suffixIcon: IconButton(
                                    icon: (isVisible == false)
                                        ? const Icon(Icons.visibility_off)
                                        : const Icon(Icons.visibility),
                                    onPressed: () {
                                      if (isVisible == true) {
                                        setState(() {
                                          isVisible = false;
                                        });
                                      } else {
                                        setState(() {
                                          isVisible = true;
                                        });
                                      }
                                    },
                                  )),
                              validator: validatePassAgain,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    loginWithPhone = !loginWithPhone;
                                    codeSent = false;
                                    verificationCode = "";
                                  });
                                },
                                child: Text(
                                  (!loginWithPhone)
                                      ? 'Telefon ile Kayıt Ol'
                                      : 'E-Mail ile Kayıt Ol',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorConstants.instance.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: GradientButton(
                              start: ColorConstants.instance.primaryColor,
                              end: ColorConstants.instance.secondaryColor,
                              buttonText: (loginWithPhone)
                                  ? (codeSent)
                                      ? 'Kodu Doğrula'
                                      : 'Doğrulama Kodu Al'
                                  : 'Kayıt Ol',
                              fontSize: 15,
                              onPressed: (loginWithPhone)
                                  ? (codeSent)
                                      ? verifyCode
                                      : verifyPhone
                                  : signUp,
                              icon: FontAwesomeIcons.signInAlt,
                              widthMultiplier: 0.9,
                            )),
                      ],
                    ),
                  ),
                ),
              )
            : const ProgressWidget());
  }
}
