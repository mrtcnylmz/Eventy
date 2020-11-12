import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginSayfasi extends StatefulWidget {
  @override
  _LoginSayfasiState createState() => _LoginSayfasiState();
}

class _LoginSayfasiState extends State<LoginSayfasi> {
  String _sifre;
  String _eposta;
  bool vis = true;
  final _kayitKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _kayitKey,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Container(
                child: Text("Eventy",
                    style: GoogleFonts.itim(
                      textStyle: TextStyle(
                        fontSize: 60,
                        color: Colors.red,
                      ),
                    )),
              ),
              Container(
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 200,
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => node.nextFocus(),
                  onSaved: (value) {
                    setState(() {
                      _eposta = value;
                    });
                  },
                  validator: (email) {
                    Pattern pattern =
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                    RegExp regex = new RegExp(pattern);
                    if (email.isEmpty)
                      return 'Email Kısmı Boş Olamaz.';
                    else if (!regex.hasMatch(email))
                      return 'Email Adresinizi kontrol edin. ';
                    else
                      return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    focusColor: Colors.red,
                    icon: Icon(Icons.account_box_rounded),
                    labelText: "E-Mail",
                    hintText: "E-Mail",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: TextFormField(
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (_kayitKey.currentState.validate()) {
                      _kayitKey.currentState.save();
                      _userLogin(_eposta, _sifre);
                      debugPrint(_eposta +
                          " Email'i ile ve " +
                          _sifre +
                          " şifresiyle Giriş Yapılacak.");
                      // TODO buraya login gelecek
                    }
                  },
                  onSaved: (value) {
                    setState(() {
                      _sifre = value;
                    });
                  },
                  validator: (value) {
                    if (value.length < 6) {
                      return 'Şifre 6 Karakterden Az Olamaz';
                    } else
                      return null;
                  },
                  enableSuggestions: false,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: vis,
                  autocorrect: false,
                  decoration: InputDecoration(
                    suffixIcon: InkWell(
                      child: Icon(Icons.remove_red_eye),
                      onTap: () {
                        setState(() {
                          vis = vis == false ? true : false;
                        });
                      },
                    ),
                    icon: Icon(Icons.lock),
                    labelText: "Şifre",
                    hintText: "Şifre",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                width: 200,
                child: RaisedButton(
                  color: Colors.green,
                  onPressed: () {
                    if (_kayitKey.currentState.validate()) {
                      _kayitKey.currentState.save();
                      _userLogin(_eposta, _sifre);
                      debugPrint(_eposta +
                          " Email'i ile ve " +
                          _sifre +
                          " şifresiyle Giriş Yapılacak.");
                      // TODO buraya login gelecek
                    }
                  },
                  child: Text(
                    "Giriş Yap",
                  ),
                ),
              ),
              Container(
                child: FlatButton(
                  color: Colors.green,
                  onPressed: () {
                    Navigator.pushNamed(context, '/userKayıt');
                  },
                  child: Text("Kaydol"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _userLogin(String email, String password) async {
    try {
      UserCredential _userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      debugPrint("Giriş Yapılan Kullanıcı: " + _userCredential.user.email);
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        if (user == null) {
          print('Kullanıcı Çıkış Yaptı!');
        } else {
          print('Kullanıcı Giriş Yaptı!');
        }
      });
      if (_auth.currentUser != null) {
        print(_auth.currentUser.uid);
        print(_auth.currentUser.email);
      }
      Navigator.of(context).pushNamed('/haritay');
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Hata"),
            content: Text(e.toString()),
            actions: [
              FlatButton(
                child: Text("Tamam"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
}