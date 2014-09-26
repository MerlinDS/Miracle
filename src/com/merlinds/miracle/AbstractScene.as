/**
 * User: MerlinDS
 * Date: 18.04.2014
 * Time: 18:42
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.utils.Asset;
	import com.merlinds.miracle.utils.MafReader;
	import com.merlinds.miracle.utils.MtfReader;

	import flash.display3D.Context3D;

	internal class AbstractScene implements IRenderer{

		protected var _scale:Number;
		protected var _context:Context3D;
		//maps
		protected var _displayObjects:Vector.<MiracleDisplayObject>;

		protected var _meshes:Object;/**Mesh2D**/
		protected var _textures:Object;/**TextureHelper**/
		protected var _animations:Object;/**AnimationHelper**/

		private var _mtfReader:MtfReader;
		private var _mafReader:MafReader;

		public function AbstractScene(assets:Vector.<Asset>, scale:Number = 1) {
			_scale = scale;
			_meshes = {};
			_textures = {};
			_animations = {};
			_displayObjects = new <MiracleDisplayObject>[];
			_mafReader = new MafReader();
			_mtfReader = new MtfReader();
			this.initialize(assets);
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		public function start():void {
			_context.clear(0.8, 0.8, 0.8, 1);
		}

		public function end(present:Boolean = true):void {
		}

		public function kill():void {
			_context = null;
		}

		public function drawFrame(time:Number):void {
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		[Inline]
		protected final function initialize(assets:Vector.<Asset>):void{
			//Initialization complete
			while(assets.length > 0){
				var asset:Asset = assets.pop();
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
				//Other types will be ignored for now!
				//TODO: clear readers
				asset.destroy();
			}
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
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
