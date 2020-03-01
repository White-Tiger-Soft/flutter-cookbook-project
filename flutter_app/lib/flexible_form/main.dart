import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: true,
        body: SafeArea(
          child: MyPage(),
        ),
      ),
    );
  }
}

class MyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyPageState();
  }
}

class MyPageState extends State<MyPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _buildBody(context),
        resizeToAvoidBottomPadding: false,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    var maxHeight = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (context, constraints) {
        print("min height ${constraints.maxHeight}, $maxHeight");
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight, maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Spacer(flex: 50),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: _buildLogo(context),
                ),
                Spacer(flex: 50),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: _buildForm(context),
                ),
                Spacer(flex: 100),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: _buildFooter(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Placeholder(
      fallbackHeight: 100,
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        color: Colors.blueGrey.withOpacity(0.25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              initialValue: "Field 1 Value",
            ),
            TextFormField(
              initialValue: "Field 2 Value",
            ),
            TextFormField(
              initialValue: "Field 3 Value",
            ),
            FlatButton(
              child: Text("Submit Form"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Text(
      "Нажимая на кнопку Войти вы соглашаетесь с Политикой конфиденциальности и Условиями использования",
    );
  }
}
