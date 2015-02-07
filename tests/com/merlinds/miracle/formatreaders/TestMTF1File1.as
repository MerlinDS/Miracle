/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 10:11
 */
package com.merlinds.miracle.formatreaders {
	import flash.utils.ByteArray;

	public class TestMTF1File1 extends ByteArray{

		private var _charSet:String;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function TestMTF1File1(charSet:String) {
			_charSet = charSet;
			this.create();
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function create():void {
			this.position = 0;
			//write signature
			this.writeMultiByte(Signatures.MTF1, _charSet);
			//write header
			this.writeShort(4);//float type
			this.writeShort(4);//float type
			this.writeShort(4);//float type
			this.writeMultiByte("ATF", _charSet);
			this.position = TextureHeadersFormat.DATE;
			this.writeInt(new Date().getTime());
			//write linkers block
			var testData:Object = {
				vertices:[1,2,3,4,5,6,7,8],
				uv:[1,2,3,4,5,6,7,8],
				indexes:[1,2,3,4,5,6]
			};
			this.openNewLinkBlock("ball", true);
			this.writeLinkUnit("ball_image", testData);
			this.openNewLinkBlock("shapes");
			this.writeLinkUnit("circle", testData);
			this.writeLinkUnit("rect", testData);
			//write data block
			//write textures bytes
		}

		private function openNewLinkBlock(name:String, isFirst:Boolean = false):void {
			if(!isFirst)
				this.writeByte(ControlCharacters.GS);
			this.writeUTFBytes(name);
			this.writeByte(ControlCharacters.US);
		}

		private function writeLinkUnit(name:String, data:Object):void {
			this.writeUTFBytes(name);
			this.writeByte(ControlCharacters.ETB);
			this.writeShort(4);//Number of points
			this.writeShort(6);//Number of indexes
			this.writeByte(ControlCharacters.US);
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}
