/* -------------------------------- *\
	Import
\* -------------------------------- */
import peasy.*;
import processing.serial.*;
import ddf.minim.*;

/* -------------------------------- *\
	Global
\* -------------------------------- */
// Processing load
boolean loaded = false;
// Serial
int serialVal;
// Control
float control_z;
float control_y;
int control_speed = 10;
int distance; // from ultrasonic
int boost = 0;
int last_boost = 0;
// Logo animation
int text_size = 2352;
// Game setting
int flying_speed;
int flying_speed_base = 0;
int max_life = 3;
// Game state
String gameState = "logo";
boolean stick_right = false;
boolean stick_left = false;
boolean stick_up = false;
boolean stick_lock = false;
int last_stick = millis();

boolean level_selected = false; // select page
boolean final_entered = false; // final page
boolean gameEnd = false;

String lastLevel;
// Scene setting
int num_clouds = 25;
int num_canyons = 2;
int num_rains = 400;
int num_seas = 2;
// Coins
int num_coins = 10;

// Serial object
Serial serialPort;
// Cam object
PeasyCam camera;
// Fonts object
PFont righteous;
// Players
Minim minim;
AudioPlayer logoPlayer;
AudioPlayer selectPagePlayer;
AudioPlayer finalPagePlayer;
AudioPlayer focusPlayer;
AudioPlayer enterPlayer;
AudioPlayer airplanePlayer;
AudioPlayer goPlayer;
AudioPlayer ringPassPlayer;
AudioPlayer ringFailPlayer;
AudioPlayer coinPlayer;
AudioPlayer deadPlayer;
AudioPlayer windyPlayer1;
AudioPlayer windyPlayer2;
AudioPlayer rainPlayer;
AudioPlayer thunderPlayer1;
AudioPlayer thunderPlayer2;
AudioPlayer theme1Player;
AudioPlayer theme2Player;
AudioPlayer theme3Player;

// Select Page objects
SelectPage selectPage;
FinalPage finalPage;
// Game objects
Scene scene;
Cloud[] clouds = new Cloud[num_clouds];
PImage lightningImg;
Airplane airplane;
Ring ring;
Coin[] coins = new Coin[num_coins];
Canyon[] canyons = new Canyon[num_canyons];
Rain[] rains = new Rain[num_rains];
Sea[] seas = new Sea[num_seas];
GamePlay gamePlay;
StatusPanel statusPanel;
PImage starIcon;
PImage trophyIcon;
PImage underLayer_r;
PImage underLayer_c;
PImage underLayer_scl;
PImage underLayer_scr;
PImage heart_f;
PImage heart_e;

/* -------------------------------- *\
	Setup
\* -------------------------------- */
void setup() {
	// Display
	fullScreen(P3D);
	frameRate(70);
	
	// Serial
	String portName ="COM4";
	serialPort = new Serial(this, portName, 115200);

	// Fonts
	righteous = createFont("fonts/Righteous-Regular.ttf",128);
	
	// Camera init
	camera = new PeasyCam(this,0,0,0,936);
	camera.rotateY(-HALF_PI);
	camera.lookAt(0,height/2,width/2,0);
	
	// Use thead to load because they are waiting too long.
	thread("loadFiles");
}

/* -------------------------------- *\
	Draw
\* -------------------------------- */
synchronized void draw() {
	// Procesing loading
	if (!loaded){
		pushMatrix();
		background(0);
		rotateY(-HALF_PI);
		textFont(righteous);
		textSize(50);
		fill(255);
		text("LOADING...",width-textWidth("LOADING...")-100,height-100);
		popMatrix();
	// Normal drawing
	} else {
		/* -------------------------------- *\
			Display setting
		\* -------------------------------- */
		// println(frameRate);

		/* -------------------------------- *\
			IO setting
		\* -------------------------------- */
		// Control by "Joystick"
		if (((gameState=="select")||(gameState=="final"))  && !stick_lock){
			if ((serialVal & 0x04) == 0x04) stick_left = true;
			else stick_left = false;
			if ((serialVal & 0x08) == 0x08) stick_right = true;
			else stick_right = false;
			if ((serialVal & 0x02) == 0x02) stick_up = true;
			else stick_up = false;
		} else if (((gameState=="L1")||(gameState=="L2")||(gameState=="L3")||(gameState=="test")) && !stick_lock){
			if ((serialVal & 0x01) == 0x01){ // stick down
				control_y+=control_speed;
			}
			if ((serialVal & 0x02) == 0x02){ // stick up
				control_y-=control_speed;
			}
			if ((serialVal & 0x04) == 0x04){ // stick left
				control_z-=control_speed*1.5;
			}
			if ((serialVal & 0x08) == 0x08){ // stick right
				control_z+=control_speed*1.5;
			}

			// Control by "Mouse"
			// control_z = mouseX;
			// control_y = mouseY;

			// Control range restrict (optional)
			if (control_z >= 1620) control_z = 1620;
			if (control_z <= 300) control_z = 300;
			if (control_y >= 980) control_y = 980;
			if (control_y <= 100) control_y = 100;
		}

		// Ultrasonic
		distance = (serialVal & 0xF0) >> 4;
		boost = 5*(15-distance)-25; // form 0 to 45
		if (boost < 0) boost = 0;
		else if (boost == 50) boost = last_boost;
		else last_boost = boost;

		flying_speed = flying_speed_base + boost;
		// println(flying_speed);

		/* -------------------------------- *\
			Game State
		\* -------------------------------- */
		switch(gameState){
			case "logo":
				// Display logo
				logoDisplay();
				if (frameCount >= 560) gameState = "select";
				break;
			case "select":
				selectPage.display();
				if (level_selected && selectPage.select_focus == 0) {
					selectPage.select_focus = 0;
					level_selected = false;
					stick_lock = false;
					gameState = "L1";
				} else if (level_selected && selectPage.select_focus == 1) {
					selectPage.select_focus = 0;
					level_selected = false;
					stick_lock = false;
					gameState = "L2";
				} else if (level_selected && selectPage.select_focus == 2) {
					selectPage.select_focus = 0;
					level_selected = false;
					stick_lock = false;
					gameState = "L3";
				}
				break;
			case "L1":
				scene.display(1);
				statusPanel.display();
				gamePlay.play("easy");
				// BGM
				theme1Player.play();
				if (theme1Player.position()>=theme1Player.length()) theme1Player.rewind();
				if (gameEnd) {
					theme1Player.pause();
					theme1Player.rewind();
					gameState = "final";
				}
				break;
			case "L2":
				scene.display(2);
				statusPanel.display();
				gamePlay.play("medium");
				theme2Player.play();
				if (theme2Player.position()>=theme2Player.length()) theme2Player.rewind();
				if (gameEnd) {
					theme2Player.pause();
					theme2Player.rewind();
					gameState = "final";
				}
				break;
			case "L3":
				scene.display(3);
				statusPanel.display();
				gamePlay.play("hard");
				theme3Player.play();
				if (theme3Player.position()>=theme3Player.length()) theme3Player.rewind();
				if (gameEnd) {
					theme3Player.pause();
					theme3Player.rewind();
					gameState = "final";
				}
				break;
			case "final":
				// Stop all the audios in game levels
				if (gameEnd){
					windyPlayer1.pause();
					windyPlayer2.pause();
					rainPlayer.pause();
					thunderPlayer1.pause();
					thunderPlayer2.pause();
					windyPlayer1.rewind();
					windyPlayer2.rewind();
					rainPlayer.rewind();
					thunderPlayer1.rewind();
					thunderPlayer2.rewind();
				}
				finalPage.display();
				if (final_entered && finalPage.select_focus == 0){
					if (lastLevel == "L1") {
						resetAll();
						gameState = "L1";
					}
					else if (lastLevel == "L2") {
						resetAll();
						gameState = "L2";
					}
					else if (lastLevel == "L3") {
						resetAll();
						gameState = "L3";
					}
				} else if (final_entered && finalPage.select_focus == 1) {
					resetAll();
					gameState = "select";
				}
				break;
			case "test":
				break;
		}
	} 
}

/* -------------------------------- *\
	Reset
\* -------------------------------- */
void resetAll(){
	// game flow
	level_selected = false;
	final_entered = false;
	gameEnd = false;
	// game reset
	gamePlay.reset();
	// Page reset
	selectPage.reset();
	finalPage.reset();
}

/* -------------------------------- *\
	Loading files
\* -------------------------------- */
void loadFiles(){
	// Control
	control_z = width/2;
	control_y = height/2;
	
	// Select Page
	selectPage = new SelectPage();
	finalPage = new FinalPage();
	
	// Game objects
	scene = new Scene();
	for (int i = 0; i < clouds.length; i++){
		clouds[i] = new Cloud("./objects/cloud/cloud.obj");
	}
	for (int i = 0; i < canyons.length; i++){
		canyons[i] = new Canyon("./objects/canyon/canyon.obj");
	}
	for (int i = 0; i < rains.length; i++){
		rains[i] = new Rain();
	}
	for (int i = 0; i < seas.length; i++){
		seas[i] = new Sea("./objects/sea/sea.obj");
	}
	lightningImg = loadImage("./images/lightning.png");
	airplane = new Airplane(
		"./objects/biplane/biplane.obj",
		"./objects/biplane/diffuse_512.png");
	ring = new Ring("./objects/ring/ring.obj");
	for (int i = 0; i < coins.length; i++){
		coins[i] = new Coin("./objects/coin/coin.obj");
	}
	statusPanel = new StatusPanel();
	
	// Game Play
	gamePlay = new GamePlay();
	starIcon = loadImage("./images/star.png");
	trophyIcon = loadImage("./images/trophy.png");
	underLayer_r = loadImage("./images/underlayer_r.png");
	underLayer_c = loadImage("./images/underlayer_c.png");
	underLayer_scr = loadImage("./images/underlayer_scr.png");
	underLayer_scl = loadImage("./images/underlayer_scl.png");
	heart_f = loadImage("./images/heart_f.png");
	heart_e = loadImage("./images/heart_e.png");
	
	// Audios
	minim = new Minim(this);
	logoPlayer = minim.loadFile("./audios/logo_animaiton/POL-cinematic-riser-07.wav");
	selectPagePlayer = minim.loadFile("./audios/common/Feelin' Good.mp3");
	finalPagePlayer = minim.loadFile("./audios/common/One_Step_Closer.mp3");
	focusPlayer = minim.loadFile("./audios/common/focus_effect.wav");
	enterPlayer = minim.loadFile("./audios/common/enter_effect.wav");
	airplanePlayer = minim.loadFile("./audios/airplane/airplane.wav");
	goPlayer = minim.loadFile("./audios/common/go.wav");
	ringPassPlayer = minim.loadFile("./audios/common/ring_pass.mp3");
	ringFailPlayer = minim.loadFile("./audios/common/ring_fail.wav");
	coinPlayer = minim.loadFile("./audios/common/coin.mp3");
	deadPlayer = minim.loadFile("./audios/common/dead.mp3");
	windyPlayer1 = minim.loadFile("./audios/theme_1/windy_quiet.wav");
	windyPlayer2 = minim.loadFile("./audios/theme_2/windy.wav");
	rainPlayer = minim.loadFile("./audios/theme_3/rain_strom.mp3");
	thunderPlayer1 = minim.loadFile("./audios/theme_3/thunder_1.mp3");
	thunderPlayer2 = minim.loadFile("./audios/theme_3/thunder_2.mp3");
	theme1Player = minim.loadFile("./audios/theme_1/Glen_Canyon.mp3");
	theme2Player = minim.loadFile("./audios/theme_2/Spring.mp3");
	theme3Player = minim.loadFile("./audios/theme_3/Orbital_Romance.mp3");
	
	synchronized(this){
		loaded = true;
	}
}

/* -------------------------------- *\
	Serial Event
\* -------------------------------- */
void serialEvent(Serial s) { 
	serialVal = s.read(); 
	// println(serialVal);
}

/* -------------------------------- *\
	Logo animation
\* -------------------------------- */
void logoDisplay(){
	background(#000000);
	// animation
	if (text_size <= 64) text_size = 64;
	else text_size-=16;
	String text = "JOEY GAME";
	pushMatrix();
	rotateY(-HALF_PI);
	translate(width/2, height/2, 0);
	fill(#ffffff);
	textFont(righteous);
	textSize(text_size);
	text(text,-textWidth(text)/2,0,0);
	popMatrix();
	// audio
	logoPlayer.play();
}

/* -------------------------------- *\
	functions for developers
\* -------------------------------- */
void drawBaseline(){
	// screen
	pushMatrix();
	rotateY(-HALF_PI);
	noFill();
	stroke(#000000);
	rect(0,0,width,height);
	popMatrix();

	// gaming range
	pushMatrix();
	translate(0,height/2-340,width/2-560);
	rotateY(-HALF_PI);
	noFill();
	stroke(#ff0000);
	rect(0, 0, 1120, 680);
	popMatrix();
}