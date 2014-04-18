/**
 * User: MerlinDS
 * Date: 18.04.2014
 * Time: 18:42
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.meshes.Mesh2D;
	import com.merlinds.miracle.meshes.Polygon2D;
	import com.merlinds.miracle.textures.TextureHelper;
	import com.merlinds.miracle.utils.Asset;
	import com.merlinds.miracle.utils.AtfData;

	import flash.display3D.Context3D;

	internal class AbstractScene implements IRenderer{

		protected var _context:Context3D;
		//maps
		protected var _displayObjects:Vector.<MiracleDisplayObject>;

		protected var _meshes:Object;/**Mesh2D**/
		protected var _textures:Object;/**Texture**/

		public function AbstractScene(assets:Vector.<Asset>) {
			_meshes = {};
			_textures = {};
			_displayObjects = new <MiracleDisplayObject>[];
			this.initialize(assets);
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		public function start():void {
			_context.clear(0.8, 0.8, 0.8, 1);
		}

		public function end():void {
		}

		public function kill():void {
			_context = null;
		}

		public function drawFrame():void {
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		[Inline]
		protected function initialize(assets:Vector.<Asset>):void{
			//Initialization complete
			while(assets.length > 0){
				var asset:Asset = assets.pop();
				if(asset.type == Asset.MESH_TYPE){
					//parse meshes
					var mesh:Mesh2D = new Mesh2D();
					var meshData:Array = asset.output;
					var n:int = meshData.length;
					for(var i:int = 0; i < n; i++){
						mesh[i] = new Polygon2D(meshData[i]);
					}
					_meshes[ asset.name ] = mesh;
				}else if(asset.type == Asset.TEXTURE_TYPE){
					//parse textures
					_meshes[ asset.name ] = new TextureHelper( asset.output );
					AtfData.getAtfParameters(_meshes[ asset.name ]);
				}
				//Other types will be ignored for now!
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
		//} endregion GETTERS/SETTERS ==================================================
	}
}
