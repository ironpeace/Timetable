package muit.timetable.parts
{
	import mx.controls.ProgressBar;
	
	import spark.components.BorderContainer;
	
	public class LoadingCurtain extends BorderContainer
	{
		private var loader:ProgressBar = new ProgressBar();
		
		public function LoadingCurtain()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			loader.indeterminate = true;
			loader.label = "";
			this.addElement(loader);
			
			super.createChildren();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			this.setStyle("backgroundColor", 0xffffff);
			this.setStyle("backgroundAlpha", 0.5);
			
			loader.width = unscaledWidth / 2;
			loader.setStyle("trackHeight", 10);
			loader.x = (unscaledWidth - loader.width) / 2;
			loader.y = (unscaledHeight - loader.height) / 2;			
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
	}
}