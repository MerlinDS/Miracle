/**
 * User: MerlinDS
 * Date: 03.04.2014
 * Time: 20:56
 */
package com.merlinds.miracle.display {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.events.MiracleEvent;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.miracle_internal;

	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	/**
	 * Will be dispatched when instance was added to stage.
	 * If mesh or animation was changed will be dispatched again after drawing on stage with new parameters
	 */
	[Event(type="com.merlinds.miracle.events.MiracleEvent", name="addedToStage")]
	/**
	 * Will be dispatched when instance was removed from stage.
	 * If mesh or animation was changed will be dispatched to
	 */
	[Event(type="com.merlinds.miracle.events.MiracleEvent", name="removedFromStage")]
	public class MiracleDisplayObject extends EventDispatcher{

		use namespace miracle_internal;
		//description
		private var _mesh:String;
		private var _animation:String;
		private var _animationId:String;
		private var _currentFrame:int;
		private var _visible:Boolean;
		internal var _isAnimated:Boolean;
		//Transformations
		public var transformation:Transformation;
		public var z:Number;
		//Playback
		private var _onStage:Boolean;
		//
		private var _demandAnimationInstance:Boolean;
		private var _animationInstance:AnimationHelper;

		public function MiracleDisplayObject() {
			this.transformation = new Transformation( new TransformMatrix(), new Color(), new Rectangle());
			_currentFrame = 0;
			_visible = true;
			this.z = 0;
		}

		//==============================================================================
		//{region							PUBLIC METHODS

		public function hitTest(point:Point):Boolean {
			//temp
			var rect:Rectangle = this.transformation.bounds.clone();
			rect.offset(this.transformation.matrix.tx, this.transformation.matrix.ty);
			return rect.containsPoint(point);
		}
		/**
		 * move instance to new coordinates
		 * @param x
		 * @param y
		 * @param z
		 * @return Current instance
		 */
		public function moveTO(x:Number = 0, y:Number = 0, z:Number = 0):MiracleDisplayObject {
			this.transformation.matrix.tx = x;
			this.transformation.matrix.ty = y;
			//TODO MF-41 Add z-index sorting
			return this;
		}

		miracle_internal function drawn():void{
			if(!_onStage){
				//After first draw dispatch event that display object was added to stage
				if(this.hasEventListener(MiracleEvent.ADDED_TO_STAGE)){
					this.dispatchEvent(new MiracleEvent(MiracleEvent.ADDED_TO_STAGE));
				}
				_onStage = true;
				this.afterDraw();
			}
		}

		miracle_internal function remove():void{
			if(_onStage){
				if(this.hasEventListener(MiracleEvent.REMOVED_FROM_STAGE)){
					this.dispatchEvent(new MiracleEvent(MiracleEvent.REMOVED_FROM_STAGE));
				}
				_currentFrame = 0;
				_onStage = false;
				this.afterRemove();
			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		protected function afterDraw():void{

		}

		protected function afterRemove():void{

		}

		protected final function demandAnimationInstance():void {
			if(_animation != null && _mesh != null){
				_demandAnimationInstance = true;
			}else{
				throw new ArgumentError("Can not demand animation instance " +
						"without animation name and mesh name declaration");
			}
		}

		protected function afterAnimationDemand():void{

		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		/**
		 * @private
		 */
		public final function get animation():String {
			return _animation;
		}

		/**
		 * Name of the animation that will be used for this display object
		 */
		public final function set animation(value:String):void {
			if(value != _animation){
				_animation = value;
				_currentFrame = 0;
				_animationId = _mesh + "." + _animation;
				this.miracle_internal::remove();
			}
		}

		/**
		 * @private
		 */
		public final function get mesh():String {
			return _mesh;
		}

		/**
		 * Name of the mesh that will be used for this display object
		 */
		public final function set mesh(value:String):void {
			if(value != _mesh){
				_mesh = value;
				_animationId = _mesh + "." + _animation;
				this.miracle_internal::remove();
			}
		}

		public final function get animationId():String{
			return _animationId;
		}

//Transformations

		public function get width():int {
			return this.transformation.bounds.width;
		}

		public function get height():int {
			return this.transformation.bounds.height;
		}

		public function get x():Number {
			return this.transformation.matrix.tx;
		}

		public function set x(value:Number):void {
			this.transformation.matrix.tx = value;
		}

		public function get y():Number {
			return this.transformation.matrix.ty;
		}

		public function set y(value:Number):void {
			this.transformation.matrix.ty = value;
		}

		public function get scaleX():Number {
			return this.transformation.matrix.scaleX;
		}

		public function set scaleX(value:Number):void {
			this.transformation.matrix.scaleX = value;
		}

		public function get scaleY():Number {
			return this.transformation.matrix.scaleY;
		}

		public function set scaleY(value:Number):void {
			this.transformation.matrix.scaleY = value;
		}

		public function get skewX():Number {
			return this.transformation.matrix.skewX;
		}

		public function set skewX(value:Number):void {
			this.transformation.matrix.skewX = value;
		}

		public function get skewY():Number {
			return this.transformation.matrix.skewY;
		}

		public function set skewY(value:Number):void {
			this.transformation.matrix.skewY = value;
		}

		public function set direction(value:int):void {
			value = value < 0 ? -1 : 1;
			this.transformation.matrix.flipX = value;
			this.transformation.matrix.scaleX *= value;
		}

		public function get direction():int {
			return this.transformation.matrix.flipX;
		}

		public function get alpha():Number {
			//revert alphaMultiplier to alpha value
			return 1 - this.transformation.color.alphaMultiplier;
		}

		public function set alpha(value:Number):void {
			//fix value if it not in 0 1 diapason
			value = value > 1 ? 1: value < 0 ? 0 : value;
			value = 1 - value;//revert value for right alpha transformation
			this.transformation.color.alphaMultiplier = value;
			if(value > 0){
				this.transformation.color.type += Color.ALPHA;
			}else if((this.transformation.color.type & Color.ALPHA) != 0){
				this.transformation.color.type -= Color.ALPHA;
			}
		}

		public function get visible():Boolean {
			return _visible;
		}

		public function set visible(value:Boolean):void {
			_visible = value;
		}

		public function set position(value:Vector3D):void {
			this.transformation.matrix.tx = value.x;
			this.transformation.matrix.ty = value.y;
		}

		public function get isAnimated():Boolean {
			return _isAnimated;
		}

		//end of transformations
		//playback
		public function get currentFrame():int {
			return _currentFrame;
		}

		public function set currentFrame(value:int):void {
			_currentFrame = value;
		}


		protected final function get animationInstance():AnimationHelper {
			return _animationInstance;
		}

		miracle_internal function set animationInstance(value:AnimationHelper):void {
			_animationInstance = value;
			this.afterAnimationDemand();
		}

		miracle_internal function get demandAnimationInstance():Boolean {
			return _demandAnimationInstance;
		}

		public function get onStage():Boolean {
			return _onStage;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
