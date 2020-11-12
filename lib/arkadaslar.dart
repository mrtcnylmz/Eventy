import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Arkadaslar extends StatefulWidget {
  @override
  _ArkadaslarState createState() => _ArkadaslarState();
}

class _ArkadaslarState extends State<Arkadaslar> {
  String _eposta;
  final _ekleKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Arkadaş Ekle"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.group_add),
          )
        ],
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _ekleKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
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
                              return 'Email Alanı Boş Olamaz.';
                            else if (!regex.hasMatch(email))
                              return 'Geçerli Bir Email Giriniz.';
                            else
                              return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            icon: Icon(Icons.person_search),
                            labelText: "Arkadaşınızın Email'i",
                            hintText: "Email",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        flex: 6,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: RaisedButton(
                          onPressed: () {
                            if (_ekleKey.currentState.validate()) {
                              _ekleKey.currentState.save();
                              debugPrint(_eposta);
                              _firestore
                                  .collection("users")
                                  .doc(_eposta)
                                  .update({
                                "bekleyenIstekler": FieldValue.arrayUnion(
                                    [_auth.currentUser.email])
                              });
                            }
                          },
                          child: Text(
                            "Davet Gönder",
                            textAlign: TextAlign.center,
                          ),
                          color: Colors.blue[300],
                        ),
                        flex: 2,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Text(
                  "Davetler",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FutureBuilder(
                future: _firestore
                    .collection('users')
                    .doc(_auth.currentUser.email)
                    .get(),
                builder: (BuildContext content, snapyshot) {
                  try {
                    return Expanded(
                      child: snapyshot.data['arkadaslar'].toString() == "[]"
                          ? Text(
                              "Henüz Bir Arkadaşlık Davetiniz Yok.",
                              style: TextStyle(fontSize: 25),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount:
                                  snapyshot.data['bekleyenIstekler'].length,
                              itemBuilder: (BuildContext context, int index) {
                                return FutureBuilder(
                                  future: _firestore
                                      .collection('users')
                                      .doc(snapyshot.data['bekleyenIstekler']
                                          [index])
                                      .get(),
                                  builder: (BuildContext context, snap) {
                                    try {
                                      return Column(
                                        children: [
                                          ListTile(
                                            leading: InkWell(
                                              onTap: () {
                                                _firestore
                                                    .collection('users')
                                                    .doc(
                                                        _auth.currentUser.email)
                                                    .update({
                                                  'arkadaslar':
                                                      FieldValue.arrayUnion(
                                                          [snap.data['email']])
                                                });
                                                _firestore
                                                    .collection('users')
                                                    .doc(
                                                        _auth.currentUser.email)
                                                    .update({
                                                  'bekleyenIstekler':
                                                      FieldValue.arrayRemove(
                                                          [snap.data['email']])
                                                });
                                                _firestore
                                                    .collection('users')
                                                    .doc(snap.data['email'])
                                                    .update({
                                                  'arkadaslar':
                                                      FieldValue.arrayUnion([
                                                    _auth.currentUser.email
                                                  ])
                                                });
                                                setState(() {});
                                              },
                                              child: Icon(
                                                Icons.person_add,
                                                size: 50,
                                              ),
                                            ),
                                            title: Text(
                                              snap.data['ad'],
                                              textAlign: TextAlign.center,
                                            ),
                                            trailing: InkWell(
                                              child: Icon(
                                                Icons.person_remove,
                                                size: 50,
                                              ),
                                              onTap: () {
                                                _firestore
                                                    .collection('users')
                                                    .doc(
                                                        _auth.currentUser.email)
                                                    .update({
                                                  'bekleyenIstekler':
                                                      FieldValue.arrayRemove(
                                                          [snap.data['email']])
                                                });
                                                setState(() {});
                                              },
                                            ),
                                            subtitle: Text(
                                              snap.data['email'],
                                              textAlign: TextAlign.center,
                                            ),
                                            tileColor: Colors.black12,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          )
                                        ],
                                      );
                                    } catch (e) {
                                      return Container();
                                    }
                                  },
                                );
                              },
                            ),
                    );
                  } catch (e) {
                    return Text("Veri Getirmede Hata");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
