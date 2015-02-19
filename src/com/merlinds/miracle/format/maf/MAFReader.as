/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 19:31
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.format.AbstractReader;

	import flash.utils.ByteArray;

	public class MAFReader extends AbstractReader{

		private var _header:MAFHeader;
		private var _animations:Object;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFReader(signature:String, bytesChunk:int = 8960) {
			super(signature, bytesChunk);
		}

		override public function read(bytes:ByteArray, ...args):void {
			super.read(bytes, args);
			_animations = args[0];

		}

		override public function dispose():void {
			_animations = null;
			_header = null;
			super.dispose();
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		/**
		 * Read file header and parse it to header object
		 */
		override protected function readFileHeader():void {
			_header = new MAFHeader();
			this.bytes.position = MAFHeaderFormat.MT;
			_header.matrixSize = this.bytes.readShort();
			this.bytes.position = MAFHeaderFormat.CT;
			_header.colorSize = this.bytes.readShort();
			this.bytes.position = MAFHeaderFormat.FT;
			_header.frameSize = this.bytes.readShort();
			this.bytes.position = MAFHeaderFormat.DATE;
			_header.modificationDate = this.bytes.readInt();
			this.methodEnded();
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
