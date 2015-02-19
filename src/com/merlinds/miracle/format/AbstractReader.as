/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 19:33
 */
package com.merlinds.miracle.format {
	import flash.utils.ByteArray;

	public class AbstractReader {

		private static const HEADER_SIZE:int = 4;

		private var _status:int;
		private var _bytesChunk:int;
		private var _charSet:String;
		private var _correctSignature:String;
		private var _endOfMethod:Boolean;
		private var _currentMethod:int;
		private var _readingMethods:Vector.<Function>;
		private var _errors:Vector.<Error>;
		//bytes
		private var _bytes:ByteArray;
		private var _signature:String;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function AbstractReader(signature:String, bytesChunk:int = 8960)
		{
			_charSet = "us-ascii";
			_bytesChunk = bytesChunk;
			_correctSignature = signature;
			_errors = new <Error>[];
			_status = ReaderStatus.WAIT;
		}

		public function read(bytes:ByteArray, ...args):void
		{
			this.dispose();
			_bytes = bytes;
			this.assert(_bytes != null, ReaderError.FILE_IS_NULL);
			this.assert(_bytes.length > HEADER_SIZE, ReaderError.BAD_FILE_SIZE);
			this.assert(_readingMethods.length > 1, ReaderError.BAD_READER_FORMAT);
			if(_status != ReaderStatus.ERROR)
			{
				_bytes.position = 0;
				_signature = _bytes.readMultiByte(Signatures.SIZE, _charSet);
				_currentMethod = 0;
				_endOfMethod = false;
				_status = ReaderStatus.PROCESSING;
				this.assert(this.isValidSignature, ReaderError.BAD_FILE_SIGNATURE);
			}
		}

		public final function readingStep():void
		{
			if(_status == ReaderStatus.PROCESSING){
				var method:Function = _readingMethods[ _currentMethod ];
				method.apply(this);
				if(_status != ReaderStatus.ERROR){
					if(_endOfMethod)_currentMethod++;
					_endOfMethod = false;
					//reading was ended successfully
					if(_currentMethod == _readingMethods.length){
						_status = ReaderStatus.READY;
					}
				}
			}
		}

		public function dispose():void
		{
			_errors.length = 0;
			_signature = null;
			_bytes = null;
			//set new status
			_status = ReaderStatus.WAIT;
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		/**
		 * Don't add this method to queue. Just override
		 * throws new Error Need to be overridden!
		 */
		protected function readFileHeader():void
		{
			throw new Error("Need to be overridden!");
		}

		protected final function methodEnded():void
		{
			_endOfMethod = true;
		}

		protected final function addReadingMethod(method:Function):AbstractReader
		{
			if(_readingMethods == null)
				_readingMethods = new <Function>[this.readFileHeader];
			if(_readingMethods.indexOf(method) < 0)
				_readingMethods.push(method);
			return this;
		}
		/**
		 * Error assertion method
		 * @param condition
		 * @param errorId
		 */
		protected final function assert(condition:Boolean, errorId:int = 0):void {
			if (!condition) {
				_errors[_errors.length] = ReaderError.castError(errorId);
				_status = ReaderStatus.ERROR;
			}
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		/** Check for file signature correctness. Return true if signature is correct, false in other case **/
		public final function get isValidSignature():Boolean {
			return _signature == _correctSignature;
		}

		/**
		 * Get reader status.
		 * @see com.merlinds.miracle.format.ReaderStatus
		 */
		public final function get status():int {
			return _status;
		}

		public final function get errors():Vector.<Error> {
			return _errors;
		}
		//protected

		protected final function get bytesChunk():int {
			return _bytesChunk;
		}

		protected final function get charSet():String {
			return _charSet;
		}

		protected final function get bytes():ByteArray {
			return _bytes;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
