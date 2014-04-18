/**
 * User: MerlinDS
 * Date: 04.04.2014
 * Time: 20:06
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.materials.Material;
	import com.merlinds.miracle.meshes.Polygon2D;
	import com.merlinds.miracle.utils.AtfData;

	import flash.utils.ByteArray;

	internal class MaterialFactory {

		public function MaterialFactory() {
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		public function createMaterial(textureData:ByteArray, meshData:Array):Material{
			var atfFormat:Object = AtfData.getAtfParameters(textureData);
			var meshList:Vector.<Polygon2D> = new <Polygon2D>[];
			if(meshData == null){
				//TODO create empty mesh by atf size
			}else{
				var n:int = meshData.length;
				for(var i:int = 0; i < n; i++){
					meshList[i] = new Polygon2D(meshData[i]);
				}
			}
			var material:Material = new Material(meshList, textureData,
					atfFormat.textureFormat, atfFormat.textureWidth,
					atfFormat.textureHeight, atfFormat.textureNum);
			return material;
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}
