//#-hidden-code
  
import UIKit
import PlaygroundSupport

//Import custom fonts
let titilliumWebBold = Bundle.main.url(forResource: "TitilliumWeb-Bold",withExtension: "ttf")! as CFURL
CTFontManagerRegisterFontsForURL(titilliumWebBold, CTFontManagerScope.process, nil)

let titilliumWebExtraLight = Bundle.main.url(forResource: "TitilliumWeb-ExtraLight",withExtension: "ttf")! as CFURL
CTFontManagerRegisterFontsForURL(titilliumWebExtraLight, CTFontManagerScope.process, nil)

let titilliumWebLight = Bundle.main.url(forResource: "TitilliumWeb-Light",withExtension: "ttf")! as CFURL
CTFontManagerRegisterFontsForURL(titilliumWebLight, CTFontManagerScope.process, nil)

let titilliumWebSemiBold = Bundle.main.url(forResource: "TitilliumWeb-SemiBold",withExtension: "ttf")! as CFURL
CTFontManagerRegisterFontsForURL(titilliumWebSemiBold, CTFontManagerScope.process, nil)
//#-end-hidden-code

/*:
 # **Puzzle Pipe**
 
 Puzzle Pipe is a **procedural puzzle game** that allows you to keep problem-solving skills in training. The purpose of the game is to connect two main pipes that are highlighted in a different color through other pipes in order to create a path that allows the two main pipes to communicate. Once you have created a valid route you can go to the next round, remember to pay attention to the time!
\
 You are free to test this playground both on Xcode and on Swift Playground on an iPad.
 
* Callout(How to Play):
 Tap on `Run My Code`, once appeared the matrix with the pipes you have to find a path, so drag a block in the direction of an empty block proceeding in this way until you find the right path that connects the two main pipes advancing to the next round.
 \
 **Reminder:** You can only move the blocks which are near to empty blocks.

 
 
 - **Bonus:** The bonus is the number of points that you gain when you complete a round, it depends on the _matrix size_, the _difficulty_ and the time. When it reach the 0 you will lose.
 
- - -
 # **Customization**
 
 **Difficulty**
 \
You can change the difficulty of the game with one of the following:
 - **.normal**: _More time and more empty blocks to move around._
 - **.hard**: _Less time, less empty blocks and fixed blocks that will hinder you._
 - **.veryHard**: _The same of hard difficulty but with less time._
 */
  GameSettings.difficulty = /*#-editable-code*/.normal/*#-end-editable-code*/
/*:
 \
 **Matrix Size**
 \
  You can change the matrix size, changing it will change the bonus points for each round.
   - Important:
   The matrix size must be greater than or equal to 3, if you enter a number less than 3 the size will be reset to the minimum allowed size (3).
 */
//#-code-completion(everything, hide)
GameSettings.matrixSize = /*#-editable-code*/3/*#-end-editable-code*/
/*:
 \
 **Shuffling**
 \
Setting this field to `false` you can start the game with the right path already positioned, change this field if you are curious to know what happens at the completion of a round without solving it.
 */
//#-code-completion(everything, hide)
GameSettings.shuffled = /*#-editable-code*/true/*#-end-editable-code*/

//#-hidden-code

//Check if the user select a matrix size less than 3x3
if GameSettings.matrixSize < 3 {
  GameSettings.matrixSize = 3
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = GameViewController()
//#-end-hidden-code
