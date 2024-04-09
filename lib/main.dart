import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_python_project/respond_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatSerivce>(
        create: (context) => ChatSerivce(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '字險戲',
          theme: ThemeData(
            primarySwatch: Colors.amber,
          ),
          home: const Menu(),
        ));
  }
}

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('images/forest_of_liars.jpg'),
                opacity: 0.8)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: (Text(
                  '字險戲',
                  style: GoogleFonts.zenKakuGothicNew().copyWith(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                )),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const GameChatPage();
                      },
                    ),
                  );
                },
                child: const Text('開始遊戲'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameChatPage extends StatefulWidget {
  const GameChatPage({super.key});

  @override
  State<GameChatPage> createState() => _GameChatPageState();
}

class _GameChatPageState extends State<GameChatPage> {
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
  @override
  void initState() {
    super.initState();

    _assetsAudioPlayer.open(
      Audio("assets/audios/Ancient_Prisoner.mp3"),
    );
    _assetsAudioPlayer.playOrPause();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build');
    return Expanded(
      child: Scaffold(
        appBar: (AppBar(
          backgroundColor: Colors.orange[400],
          title: const Text('文字冒險遊戲'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                Provider.of<ChatSerivce>(context, listen: false).message =
                    'reset';
                Provider.of<ChatSerivce>(context, listen: false).nextChat();
              },
            ),
          ],
        )),
        body: Consumer<ChatSerivce>(
          builder: (context, chatVM, child) {
            if (chatVM.needInit & mounted) {
              debugPrint('=============================>needInit');
              chatVM.firstChat();
            }
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('images/forest_of_liars.jpg'),
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 30,
                    height: 485,
                    child: Container(
                        width: MediaQuery.of(context).size.width - 30,
                        height: 485,
                        decoration:
                            BoxDecoration(color: Colors.white.withOpacity(0.9)),
                        child: Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Wrap(
                            direction: Axis.vertical,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: const Text(
                                  '故事',
                                  style: TextStyle(fontSize: 40),
                                ),
                              ),
                              chatVM.loading
                                  ? const CircularProgressIndicator()
                                  : Container(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          chatVM.conversation,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                          softWrap: true,
                                          // overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        )),
                    // Container(
                    //   decoration: const BoxDecoration(color: Colors.white),
                    //   child: Column(
                    //     children: [
                    //       const Text('Rules',
                    //           style: TextStyle(fontSize: 20)),
                    //       Text(
                    //         chatVM.rules,
                    //         style: const TextStyle(fontSize: 14),
                    //         softWrap: true,
                    //         overflow: TextOverflow.clip,
                    //       ),
                    //     ],
                    //   ),
                    // )
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 190 - 30,
                          height: 45,
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) => chatVM.message = value,
                              )),
                        ),
                        SizedBox(
                          width: 190,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () => chatVM.nextChat(),
                            child: const Text('Submit'),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
