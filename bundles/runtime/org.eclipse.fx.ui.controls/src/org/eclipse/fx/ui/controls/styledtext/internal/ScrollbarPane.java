package org.eclipse.fx.ui.controls.styledtext.internal;

import javafx.geometry.Orientation;
import javafx.scene.Node;
import javafx.scene.control.ScrollBar;
import javafx.scene.layout.Pane;
import javafx.scene.layout.Region;
import javafx.scene.shape.Rectangle;

public class ScrollbarPane<N extends Node> extends Region {

	public final ScrollBar horizontal;
	public final ScrollBar vertical;
	private Rectangle clip;
	private N center;

	public ScrollbarPane() {
		this.horizontal = new ScrollBar();
		this.horizontal.setOrientation(Orientation.HORIZONTAL);

		this.vertical = new ScrollBar();
		this.vertical.setOrientation(Orientation.VERTICAL);

		clip = new Rectangle();

		getChildren().setAll(horizontal, vertical);
	}

	public void setCenter(N center) {
		if (this.center != null) {
			this.center.setClip(null);
			getChildren().remove(this.center);
		}

		this.center = center;
		if (this.center != null) {
			this.center.setClip(clip);
			getChildren().add(0, this.center);
		}
	}

	@Override
	protected void layoutChildren() {
		int space = 0;
		int w = 16;
		this.horizontal.resizeRelocate(0, getHeight() - w, getWidth() - w , w);
		this.vertical.resizeRelocate(getWidth() - w, 0, w, getHeight()- w);

		if (this.center != null) {
			this.clip.setX(0);
			this.clip.setY(0);
			this.clip.setWidth(getWidth() - w - space);
			this.clip.setHeight(getHeight() - w - space);
			this.center.resizeRelocate(0, 0, getWidth() - w - space, getHeight() - w - space);
		}


	}


}
