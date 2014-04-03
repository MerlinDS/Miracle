/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:36
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleImage;
	import com.merlinds.miracle.meshes.Mesh2D;
	import com.merlinds.miracle.meshes.Mesh2DCollection;
	import com.merlinds.miracle.utils.Asset;

	import flash.display3D.Context3D;
	import flash.geom.Vector3D;

	internal class Scene implements IScene, IRenderer{

		private var _context:Context3D;
		//maps
		private var _meshCollection:Vector.<Mesh2DCollection>;

		public function Scene() {
			_meshCollection = new <Mesh2DCollection>[];
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		//IScene
		public function initAssets(assets:Vector.<Asset>):void {
			assets = assets.concat();//copy vector
			//parse texture data layout
			var asset:Asset;
			while(assets.length > 0){
				asset = assets.pop();
				_meshCollection[ _meshCollection.length ] = new Mesh2DCollection(
						asset.name, asset.bytes, asset.data);
				asset.destroy();
			}
			trace("Miracle: Assets was initialize");
		}

		public function createImage(name:String, position:Vector3D = null, serializer:Class = null):MiracleImage {
			var texture:Mesh2DCollection = this.getTexture(name);
			//TODO add validation
			if(texture == null){
				throw ArgumentError("Cannot find image with this name");
			}
			trace("Miracle: Image was created. Name:", name);
			return null;
		}

		public function createAnimation(name:String, position:Vector3D = null, serializer:Class = null):MiracleAnimation {
			var texture:Mesh2DCollection = this.getTexture(name);
			//TODO add validation
			if(texture == null){
				throw ArgumentError("Cannot find animation with this name");
			}
			var instance:MiracleAnimation;
			trace("Miracle: Animation was created. Name:", name);
			return null;
		}

//IRenderer
		public function start():void {
			_context.clear(0.8, 0.8, 0.8, 1);
		}

		public function end():void{
			this.drawTriangles();
			_context.present();
		}

		public function kill():void {
			_context = null;
		}

		public function setTexture(texture:Mesh2DCollection):void{

		}

		public function draw(shape:Mesh2D, tx:Number, ty:Number,
		                     scaleX:Number, scaleY:Number, skewX:Number, skewY:Number):void{

		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		[Inline]
		private function drawTriangles():void {

		}
		[Inline]
		private function getTexture(name:String):Mesh2DCollection{
			var texture:Mesh2DCollection;
			var n:int = _meshCollection.length;
			for(var i:int = 0; i < n; i++){
				texture = _meshCollection[i];
				if(texture.name == name){
					//texture was found
					break;
				}
				texture = null;
			}
			return texture;
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function set context(value:Context3D):void{
			_context = value;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
