import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final squaresPerRow = 20;
  final squaresPerColumn = 40;
  final fontStyle = TextStyle(fontSize: 20, color: Colors.white);
  final randGen = Random();

  var snake = [];
  var food = [];
  var direction = "up";
  var isPlaying = false;

  startGame() {
    const duration = Duration(milliseconds: 300);

    snake = [(squaresPerRow / 2).floor(), (squaresPerColumn / 2).floor()];
    snake.add([snake.first[0], snake.first[1] - 1]);

    createFood();
    isPlaying = true;
    Timer.periodic(duration, (Timer timer) {
      moveSnake();

      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

  bool checkGameOver() {
    if (!isPlaying ||
        snake.first[0] == 0 ||
        snake.first[0] >= squaresPerRow ||
        snake.first[1] == 0 ||
        snake.first[1] >= squaresPerColumn) {
      return true;
    }

    for (var i = 1; i < snake.length; i++) {
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1])
        return true;
    }
    return false;
  }

  endGame() {
    isPlaying = false;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: Text(
          "Score: ${snake.length - 2}",
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"))
        ],
      ),
    );
  }

  moveSnake() {
    setState(() {
      switch (direction) {
        case "up":
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;

        case "down":
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;

        case "right":
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;

        case "left":
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;
      }
      if (snake.first[0] != food[0] || snake.first[1] != food[1])
        snake.removeLast();
      else
        createFood();
    });
  }

  createFood() {
    food = [randGen.nextInt(squaresPerRow), randGen.nextInt(squaresPerColumn)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != "up" && details.delta.dy > 0)
                  direction = "down";
                else if (direction != "down" && details.delta.dy < 0)
                  direction = "up";
              },
              onHorizontalDragUpdate: (details) {
                if (direction != "left" && details.delta.dx > 0)
                  direction = "right";
                else if (direction != "right" && details.delta.dy < 0)
                  direction = "left";
              },
              child: AspectRatio(
                aspectRatio: squaresPerRow / (squaresPerColumn + 5),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: squaresPerRow),
                  itemCount: squaresPerColumn * squaresPerRow,
                  itemBuilder: (context, index) {
                    var color;
                    var x = index % squaresPerRow;
                    var y = (index / squaresPerRow).floor();

                    bool isSnakeBody = false;

                    for (var pos in snake) {
                      if (pos[0] == x && pos[1] == y) {
                        isSnakeBody = true;
                        break;
                      }
                    }

                    if (snake.first[0] == x && snake.first[1] == y)
                      color = Colors.green;
                    else if (isSnakeBody)
                      color = Colors.green[200];
                    else if (food[0] == x && food[1] == y)
                      color = Colors.red;
                    else
                      color = Colors.grey[800];

                    return Container(
                      margin: EdgeInsets.all(1),
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                  color: isPlaying ? Colors.red : Colors.blue,
                  child: Text(
                    isPlaying ? "End" : "Start",
                    style: fontStyle,
                  ),
                  onPressed: () {
                    if (isPlaying)
                      isPlaying = false;
                    else
                      startGame();
                  },
                ),
                Text(
                  "Score: ${snake.length - 2}",
                  style: fontStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
