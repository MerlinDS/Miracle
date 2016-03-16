/**
 * User: MerlinDS
 * Date: 18.04.2014
 * Time: 18:42
 */
package com.merlinds.miracle {

	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.utils.Asset;

	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	internal class AbstractScene implements IRenderer{

		protected var _scale:Number;
		protected var _passedTime:Number;
		protected var _context:Context3D;
		//maps
		protected var _meshes:Dictionary;/**Mesh2D**/
		protected var _textures:Dictionary;/**TextureHelper**/
		protected var _animations:Dictionary;/**AnimationHelper**/
		//
		protected var _drawableObjects:Vector.<MiracleDisplayObject>;
		protected var debuggable:Boolean;

		private var _initializationCallback:Function;
		//
		protected var _lastFrameTimestamp:Number;
		protected var _timer:IEventDispatcher;
		protected var _lostContextCallback:Function;

		protected var _drawScreenShot:Boolean;
		protected var _screenShotSize:Point;
		protected var _screenShotCallback:Function;

		public function AbstractScene(scale:Number = 1) {
			_drawableObjects = new <MiracleDisplayObject>[];
			_scale = scale;
			_meshes = new Dictionary();
			_textures = new Dictionary();
			_animations = new Dictionary();
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		public function create(assets:Vector.<Asset>, callback:Function):void{
			_initializationCallback = callback;
			var assetsParser:AssetsParser = new AssetsParser(assets, _meshes, _textures, _animations);
			assetsParser.execute(this.completeInitialization, _scale);
		}

		public function initialize(context:Context3D, timer:IEventDispatcher, lostContextCallback:Function):void {
			_lostContextCallback = lostContextCallback;
			_context = context;
			_timer = timer;
		}

		public function getScreenShot(width:int, height:int, callback:Function):void
		{
			_screenShotSize = new Point(width, height);
			_screenShotCallback = callback;
			_drawScreenShot = true;
		}

		public function pause():void {
			_timer.removeEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
		}

		public function resume():void {
			_lastFrameTimestamp = new Date().time;
			_timer.addEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
		}

		public function restore(callback:Function):void {

		}

		public function stopRestoring():void {

		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS

		protected function prepareFrames():void {

		}

		protected function drawFrames():void {
		}

		protected function end(present:Boolean = true):void {
			if(present) {
				_context.present();
			}
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		protected function completeInitialization():void {
			if(_initializationCallback is Function){
				_initializationCallback.apply(this);
			}
		}

		protected function enterFrameHandler(event:Event = null):void {

		}


		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function get scale():Number {
			return _scale;
		}

		public function set debugOn(value:Boolean):void
		{
			this.debuggable = value;
		}
//} endregion GETTERS/SETTERS ==================================================
	}
}

import com.merlinds.miracle.animations.AnimationHelper;
import com.merlinds.miracle.geom.Mesh2D;
import com.merlinds.miracle.utils.Asset;
import com.merlinds.miracle.utils.MafReader;
import com.merlinds.miracle.utils.MtfReader;

import flash.utils.Dictionary;

import flash.utils.setTimeout;

class AssetsParser{

	private var _assets:Vector.<Asset>;
	//maps
	private var _meshes:Dictionary;/**Mesh2D**/
	private var _textures:Dictionary;/**TextureHelper**/
	private var _animations:Dictionary;/**AnimationHelper**/
	private var _callback:Function;

	private var _mtfReader:MtfReader;
	private var _mafReader:MafReader;
	private var _scale:Number;

	public function AssetsParser(assets:Vector.<Asset>, meshes:Dictionary,
	                             textures:Dictionary, animations:Dictionary) {
		_assets = assets;
		_meshes = meshes;
		_textures = textures;
		_animations = animations;
	}


	private function complete():void{
		_callback.apply();
		_assets.length = 0;
		_assets = null;
		_meshes = null;
		_textures = null;
		_animations = null;
	}

	public function execute(callbakc:Function, scale:Number):void {
		_callback = callbakc;
		_scale = scale;
		_mafReader = new MafReader();
		_mtfReader = new MtfReader();
		this.parseAssets();
	}

	private function parseAssets():void {
		if(_assets.length > 0){
			this.parseAsset(_assets.pop());
		}else{
			this.complete();
		}
	}

	private function parseAsset(asset:Asset):void {
		if(asset.type == Asset.TEXTURE_TYPE){
			_mtfReader.execute(asset.output, _scale);
			for( var meshName:String in _mtfReader.meshes){
				var mesh2D:Mesh2D = _mtfReader.meshes[ meshName ];
				mesh2D.textureLink = asset.name;
				_meshes[ meshName ] = mesh2D;

			}
			_textures[ asset.name ] = _mtfReader.texture;
		}else{
			_mafReader.execute(asset.output, _scale);
			for each(var animation:AnimationHelper in _mafReader.animations){
				_animations[ animation.name ] = animation;
			}
		}
		asset.destroy();

		setTimeout(this.parseAssets, 0);
	}
}