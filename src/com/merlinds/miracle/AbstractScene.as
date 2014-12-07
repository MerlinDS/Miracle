/**
 * User: MerlinDS
 * Date: 18.04.2014
 * Time: 18:42
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.utils.Asset;

	import flash.display3D.Context3D;

	internal class AbstractScene implements IRenderer{

		protected var _scale:Number;
		protected var _context:Context3D;
		//maps
		protected var _meshes:Object;/**Mesh2D**/
		protected var _textures:Object;/**TextureHelper**/
		protected var _animations:Object;/**AnimationHelper**/
		//
		protected var _drawableObjects:Vector.<MiracleDisplayObject>;

		private var _initializationCallback:Function;

		public function AbstractScene(scale:Number = 1) {
			_drawableObjects = new <MiracleDisplayObject>[];
			_scale = scale;
			_meshes = {};
			_textures = {};
			_animations = {};
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		public function initialize(assets:Vector.<Asset>, callback:Function):void{
			_initializationCallback = callback;
			var assetsParser:AssetsParser = new AssetsParser(assets, _meshes, _textures, _animations);
			assetsParser.execute(this.completeInitialization, _scale);
		}

		public function start():void {
			_context.clear(0.8, 0.8, 0.8, 1);
		}

		public function end(present:Boolean = true):void {
		}

		public function kill():void {
			_context = null;
		}

		public function drawFrames(time:Number):void {
		}

		public function reload(callback:Function):void {

		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		private function completeInitialization():void {
			if(_initializationCallback is Function){
				_initializationCallback.apply(this);
			}
		}
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function set context(value:Context3D):void {
			_context = value;
		}

		public function get scale():Number{
			return _scale;
		}
//} endregion GETTERS/SETTERS ==================================================
	}
}

import com.merlinds.miracle.animations.AnimationHelper;
import com.merlinds.miracle.geom.Mesh2D;
import com.merlinds.miracle.utils.Asset;
import com.merlinds.miracle.utils.MafReader;
import com.merlinds.miracle.utils.MtfReader;

import flash.utils.setTimeout;

class AssetsParser{

	private var _assets:Vector.<Asset>;
	//maps
	private var _meshes:Object;/**Mesh2D**/
	private var _textures:Object;/**TextureHelper**/
	private var _animations:Object;/**AnimationHelper**/
	private var _callback:Function;

	private var _mtfReader:MtfReader;
	private var _mafReader:MafReader;
	private var _scale:Number;

	private var _n:int;

	public function AssetsParser(assets:Vector.<Asset>, meshes:Object,
	                             textures:Object, animations:Object) {
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