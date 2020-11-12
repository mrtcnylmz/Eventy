import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserKayitSayfasi extends StatefulWidget {
  @override
  _UserKayitSayfasiState createState() => _UserKayitSayfasiState();
}

class _UserKayitSayfasiState extends State<UserKayitSayfasi> {
  String _sifre;
  String _eposta;
  String _ad_soyad;
  bool vis = true;

  final _kayitKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Kaydol"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 25),
        child: Form(
          key: _kayitKey,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: TextFormField(
                    onSaved: (value) {
                      setState(() {
                        _ad_soyad = value;
                      });
                    },
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Ad Kısmı Boş Olamaz';
                      else
                        return null;
                    },
                    keyboardType: TextInputType.name,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      focusColor: Colors.red,
                      prefixIcon: Icon(Icons.account_circle_rounded),
                      labelText: "Ad Soyad",
                      hintText: "Ad Soyad",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: TextFormField(
                    onSaved: (value) {
                      setState(() {
                        _eposta = value;
                      });

                      debugPrint("Saved & Active");
                    },
                    validator: (email) {
                      Pattern pattern =
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                      RegExp regex = new RegExp(pattern);
                      if (email.isEmpty)
                        return 'Email Alanı Boş Olamaz.';
                      else if (!regex.hasMatch(email))
                        return 'Geçerli Bir Email Giriniz.';
                      else
                        return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      focusColor: Colors.red,
                      prefixIcon: Icon(Icons.mail),
                      labelText: "E-Mail",
                      hintText: "E-Mail",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: TextFormField(
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
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: InkWell(
                        child: Icon(Icons.remove_red_eye),
                        onTap: () {
                          setState(() {
                            vis = vis == false ? true : false;
                          });
                        },
                      ),
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
                        _userOlustur(
                            mail: _eposta, pass: _sifre, ad: _ad_soyad);
                      }
                    },
                    child: Text("Kaydol"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _userOlustur({mail, pass, ad}) async {
    String _mail = mail;
    String _pass = pass;
    String _ad = ad;

    try {
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
          email: _mail, password: _pass);
      User _yeniUser = _credential.user;
      _auth.currentUser.updateProfile(displayName: _ad);
      _firestore
          .collection("users")
          .doc(_auth.currentUser.email)
          .set({"email": _eposta, "ad": _ad_soyad});

      Navigator.of(context).pop();
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
                  })
            ],
          );
          ;
        },
      );
      debugPrint(
          "****************************************************************************************");
      debugPrint("Patladı. " + e.toString());
    }
  }
}
