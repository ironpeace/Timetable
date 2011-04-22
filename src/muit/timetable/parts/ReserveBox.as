package muit.timetable.parts
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import muit.timetable.Timetable;
	import muit.timetable.event.TimetableEvent;
	import muit.timetable.model.Reserve;
	import muit.timetable.util.DateUtil;
	
	import mx.controls.Button;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.filters.DropShadowFilter;
	
	public class ReserveBox extends BorderContainer
	{
		[Embed(source="assets/delete.png")]
		public var deleteImg:Class;

		[Embed(source="assets/edit.png")]
		public var editImg:Class;

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// PRIVATE VARIABLES
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var nameLbl:Label = new Label();
		private var deleteBtn:Button = new Button();
		private var editBtn:Button = new Button();
		private var reserveBoxFillColor:uint = 0xFFFFFF;
		private var reserveBoxAlpha:Number = 1.0;
		private var reserverNameTxtColor:uint = 0x333333;
		private var reserveBoxBorderColor:uint = 0x000000;

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// ACCESSER
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// reserve
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _reserve:Reserve;
		public function get reserve():Reserve
		{
			return _reserve;
		}
		public function set reserve(value:Reserve):void
		{
			_reserve = value;
			
			var tt:String = "";
			tt += DateUtil.be2char((value.date.month + 1).toString()) + "/" + DateUtil.be2char(value.date.date.toString());
			tt += " " + value.startTimeHour + ":" + DateUtil.be2char(value.startTimeMin.toString());
			tt += "〜" + value.endTimeHour + ":" + DateUtil.be2char(value.endTimeMin.toString());
			this.toolTip = tt;
			
			//　予約情報が更新された時に、ボックス内の表示も更新されるようにする。
			this.invalidateDisplayList();
		}

		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// positionIndex
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _positionIndex:Point = new Point();
		public function get positionIndex():Point
		{
			return _positionIndex;
		}
		public function set positionIndex(value:Point):void
		{
			_positionIndex = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// cellCount
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _cellCount:int;
		public function get cellCount():int
		{
			return _cellCount;
		}
		public function set cellCount(value:int):void
		{
			_cellCount = value;
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// positionPoint
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _positionPoint:Point = new Point();
		public function get positionPoint():Point
		{
			return _positionPoint;
		}
		public function set positionPoint(value:Point):void
		{
			_positionPoint = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// isDragging
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _isDragging:Boolean = false;
		public function get isDragging():Boolean
		{
			return _isDragging;
		}
		public function set isDragging(value:Boolean):void
		{
			_isDragging = value;
		}

		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// currentUserId
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _currentUserId:String = "";
		public function get currentUserId():String
		{
			return _currentUserId;
		}
		public function set currentUserId(value:String):void
		{
			_currentUserId = value;
		}
		
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// superUserIds
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _superUserIds:Array = new Array();
		public function get superUserIds():Array
		{
			return _superUserIds;
		}
		public function set superUserIds(value:Array):void
		{
			_superUserIds = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// CONSTRACTOR
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public function ReserveBox()
		{
			super();
			
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// OVERRIDE METHOD
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// createChildren
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		override protected function createChildren():void
		{
			super.createChildren();
			
			this.addElement(this.nameLbl);
			this.addElement(this.deleteBtn);
			this.addElement(this.editBtn);
			
			this.deleteBtn.addEventListener(MouseEvent.CLICK, deleteBtnClickHandler);
			this.editBtn.addEventListener(MouseEvent.CLICK,editBtnClickHandler);
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// commitProperties
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// updateDisplayList
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			trace("ReserveBox#updateDisplayList");
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// ドラッグ中は、ボアックス上のボタンや、ラベルを非表示にする。
			if(this.isDragging)
			{
				this.nameLbl.visible = false;
				this.deleteBtn.visible = false;
				this.editBtn.visible = false;
				this.setStyle("backgroundAlpha", this.reserveBoxAlpha);
				this.setStyle("backgroundColor", this.reserveBoxFillColor);
			}
			
			this.nameLbl.text = this.reserve.reserverName;
			this.nameLbl.setStyle("color", this.reserverNameTxtColor);
			this.nameLbl.x = 3;
			this.nameLbl.y = 3;
			
			this.deleteBtn.height = 16;
			this.deleteBtn.width = 16;
			this.deleteBtn.x = 5;
			this.deleteBtn.y = unscaledHeight - 21;
//			this.deleteBtn.setStyle("icon", deleteImg);
			this.deleteBtn.setStyle("upSkin", deleteImg);
			this.deleteBtn.setStyle("downSkin", deleteImg);
			this.deleteBtn.setStyle("overSkin", deleteImg);
			
			this.editBtn.height = 16;
			this.editBtn.width = 16;
			this.editBtn.x = 26;
			this.editBtn.y = unscaledHeight - 21;
//			this.editBtn.setStyle("icon", editImg);
			this.editBtn.setStyle("upSkin", editImg);
			this.editBtn.setStyle("downSkin", editImg);
			this.editBtn.setStyle("overSkin", editImg);
			
			if(this.isBtnVisible(this.reserve.reserverId))
			{
				this.deleteBtn.visible = true;
				this.editBtn.visible = true;
			}
			else
			{
				this.deleteBtn.visible = false;
				this.editBtn.visible = false;
			}
			
			if(0 < mouseX && mouseX < unscaledWidth && 0 < mouseY && mouseY < unscaledHeight)
			{
				this.setStyle("backgroundAlpha", 1.0);
				this.setStyle("backgroundColor", this.reserveBoxFillColor);
				this.drawResizeCorner(0xffffff, 1.0);
			}
			else
			{
				this.setStyle("backgroundAlpha", this.reserveBoxAlpha);
				this.setStyle("backgroundColor", this.reserveBoxFillColor);
				this.drawResizeCorner(0xffffff, 1.0);
			}

			var ds:DropShadowFilter = new DropShadowFilter();
			this.setStyle("borderStyle", "solid");
			this.setStyle("borderColor", this.reserveBoxBorderColor);
			this.filters = [ds];
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// EVENT HANDLER
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// mouseOverHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function mouseOverHandler(event:MouseEvent):void
		{
			this.invalidateDisplayList();
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// mouseOutHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function mouseOutHandler(event:MouseEvent):void
		{
			this.invalidateDisplayList();
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// mouseDownHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * マウスダウン時に稼働する処理
		 * リサイズカーソル上でのマウスダウンであれば、リサイズ処理が開始する。
		 * そうでなければ、ドラッグ処理が開始する。
		 *  
		 * @param event
		 * 
		 */		
		private function mouseDownHandler(event:MouseEvent):void
		{
			//ボタンの上だったら、処理キャンセル
			if(this.isOnBtn()) return;
			
			var tevent:TimetableEvent;

			if(isMouseOnResizeCorner(this.mouseX, this.mouseY))
			{
				tevent = new TimetableEvent(TimetableEvent.RESIZESTART);
			}
			else
			{
				tevent = new TimetableEvent(TimetableEvent.DRAGSTART);
			}

			tevent.reserve = this.reserve;
			this.dispatchEvent(tevent);
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// deleteBtnClickHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * 削除ボタン押下時に稼働する処理
		 *  
		 * @param event
		 * 
		 */		
		private function deleteBtnClickHandler(event:MouseEvent):void
		{
			var tevent:TimetableEvent = new TimetableEvent(TimetableEvent.RESERVE_DELETED);
			tevent.reserve = this.reserve;
			Timetable(this.owner).dispatchEvent(tevent);
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// editBtnClickHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * 編集ボタン押下時に稼働する処理
		 *  
		 * @param event
		 * 
		 */		
		private function editBtnClickHandler(event:MouseEvent):void
		{
			var tevent:TimetableEvent = new TimetableEvent(TimetableEvent.RESERVE_EDIT);
			tevent.reserve = this.reserve;
			Timetable(this.owner).dispatchEvent(tevent);
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// PUBLIC METHOD
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// drawResizeCorner
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public function setCustomStyle(fillColor:uint, alpha:Number, nameColor:uint, borderColor:uint):void
		{
			this.reserveBoxFillColor = fillColor;
			this.reserveBoxAlpha = alpha;
			this.reserverNameTxtColor = nameColor;
			this.reserveBoxBorderColor = borderColor;
			
			this.invalidateDisplayList();
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// PRIVATE METHOD
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// drawResizeCorner
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * ボックス右下のリサイズコーナーを描画する処理
		 *  
		 * @param color
		 * @param alpha
		 * 
		 */		
		private function drawResizeCorner(color:uint, alpha:Number):void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1.0, color, alpha);
			
			for each(var i:int in [20, 14, 8])
			{
				this.graphics.moveTo(this.unscaledWidth, this.unscaledHeight - i);
				this.graphics.lineTo(this.unscaledWidth - i, this.unscaledHeight);
			}

		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// isMouseOnResizeCorner
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * マウスカーソルが、リサイズコーナー上にあるかどうかを判断する処理
		 *  
		 * @param x
		 * @param y
		 * @return 
		 * 
		 */		
		private function isMouseOnResizeCorner(x:int, y:int):Boolean
		{
			if(this.unscaledHeight > y && y > this.unscaledHeight - 20
				&& this.unscaledWidth > x && x > this.unscaledWidth - 20)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private function isOnBtn():Boolean
		{
			if(this.deleteBtn.x <= this.mouseX && this.mouseX <= this.deleteBtn.x + this.deleteBtn.width 
				&& this.deleteBtn.y <= this.mouseY && this.mouseY <= this.deleteBtn.y + this.deleteBtn.height)
			{
				return true;
			}
			
			if(this.editBtn.x <= this.mouseX && this.mouseX <= this.editBtn.x + this.editBtn.width 
				&& this.editBtn.y <= this.mouseY && this.mouseY <= this.editBtn.y + this.editBtn.height)
			{
				return true;
			}
			
			return false;
		}
		
		private function isBtnVisible(reserverId:String):Boolean
		{
			//今の操作者が特権ユーザの一人なら
			if(this.superUserIds.indexOf(this.currentUserId) != -1)
			{
				return true;
			}
			
			if(this.currentUserId == reserverId)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
	}//end of class
}//end of package