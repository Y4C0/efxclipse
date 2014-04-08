/*******************************************************************************
 * Copyright (c) 2012 BestSolution.at and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Tom Schindl<tom.schindl@bestsolution.at> - initial API and implementation
 *******************************************************************************/
package org.eclipse.fx.ui.workbench.renderers.fx;

import java.util.List;

import javafx.event.ActionEvent;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.ButtonBase;
import javafx.scene.control.CheckBox;
import javafx.scene.control.RadioButton;
import javafx.scene.control.SplitMenuButton;
import javafx.scene.control.ToggleButton;

import javax.inject.Inject;
import javax.inject.Named;

import org.eclipse.e4.ui.model.application.ui.menu.ItemType;
import org.eclipse.e4.ui.model.application.ui.menu.MToolItem;
import org.eclipse.e4.ui.workbench.UIEvents;
import org.eclipse.emf.common.util.URI;
import org.eclipse.fx.ui.services.resources.GraphicsLoader;
import org.eclipse.fx.ui.workbench.renderers.base.BaseRenderer;
import org.eclipse.fx.ui.workbench.renderers.base.BaseToolItemRenderer;
import org.eclipse.fx.ui.workbench.renderers.base.widget.WToolItem;
import org.eclipse.fx.ui.workbench.renderers.fx.widget.WWidgetImpl;

/**
 * Default renderer for tool items
 */
public class DefToolItemRenderer extends BaseToolItemRenderer<Node> {

	@Override
	protected Class<? extends WToolItem<Node>> getWidgetClass(MToolItem item) {
		return ToolItemImpl.class;
	}

	/**
	 * ToolItem implementation
	 */
	public static class ToolItemImpl extends WWidgetImpl<ButtonBase, MToolItem> implements WToolItem<Node> {
		private ItemType type;
		private boolean menuButton;
		private Runnable onActionCallback;

		private boolean handled = true;
		private boolean enabled = true;
		private boolean checkbox = false;

		@Inject
		private GraphicsLoader graphicsLoader;

		/**
		 * Create an instance of a tool item
		 * 
		 * @param domElement
		 *            the model element
		 */
		@Inject
		public ToolItemImpl(@Named(BaseRenderer.CONTEXT_DOM_ELEMENT) MToolItem domElement) {
			this.type = domElement.getType();
			this.menuButton = domElement.getMenu() != null;
			this.checkbox = domElement.getTags().contains(TAG_CHECKBOX);
		}

		@Override
		protected void bindProperties(ButtonBase widget) {
			super.bindProperties(widget);
			if (widget instanceof CheckBox) {
				bindProperty(UIEvents.Item.SELECTED, ((CheckBox) widget).selectedProperty());
			} else if (widget instanceof ToggleButton) {
				bindProperty(UIEvents.Item.SELECTED, ((ToggleButton) widget).selectedProperty());
			}
		}

		@Override
		public void setHandled(boolean handled) {
			if (this.handled != handled) {
				this.handled = handled;
				updateEnabledState();
			}
		}

		private void updateEnabledState() {
			getWidget().setDisable(!(this.handled && this.enabled));
		}

		/**
		 * Update the label
		 * 
		 * @param label
		 *            the label
		 */
		@Inject
		public void setLabel(@Named(ATTRIBUTE_localizedLabel) String label) {
			getWidget().setText(label);
		}

		/**
		 * Update the enabled state
		 * 
		 * @param enabled
		 *            the enabled state
		 */
		@Inject
		public void setEnabled(@Named(UIEvents.Item.ENABLED) boolean enabled) {
			this.enabled = enabled;
			updateEnabledState();
		}

		/**
		 * Update the icon uri
		 * 
		 * @param uri
		 *            the icon uri
		 */
		@Inject
		public void setIconURI(@Named(UIEvents.UILabel.ICONURI) String uri) {
			if (uri == null) {
				getWidget().setGraphic(null);
			} else {
				getWidget().setGraphic(this.graphicsLoader.getGraphicsNode(URI.createURI(uri)));
			}
		}

		/**
		 * Update the selection state
		 * 
		 * @param selected
		 *            the new state
		 */
		@Inject
		public void setSelected(@Named(UIEvents.Item.SELECTED) boolean selected) {
			if (getWidget() instanceof CheckBox) {
				CheckBox b = (CheckBox) getWidget();
				if (b.isSelected() != selected) {
					b.setSelected(selected);
				}

			} else if (getWidget() instanceof ToggleButton) {
				ToggleButton b = (ToggleButton) getWidget();
				if (b.isSelected() != selected) {
					b.setSelected(selected);
				}
			}
		}

		@Override
		public void setOnActionCallback(Runnable onActionCallback) {
			this.onActionCallback = onActionCallback;
		}

		@Override
		protected void doCleanup() {
			super.doCleanup();
			this.onActionCallback = null;
		}

		@Override
		protected ButtonBase createWidget() {
			ButtonBase b = internalCreateWidget();
			if (b != null) {
				b.setOnAction(this::handleOnAction);
			}
			return b;
		}
		
		void handleOnAction(ActionEvent e) {
			if (this.onActionCallback != null) {
				this.onActionCallback.run();
			}
		}

		private ButtonBase internalCreateWidget() {
			switch (this.type) {
			case CHECK:
				if (this.checkbox) {
					return new CheckBox();
				} else {
					return new ToggleButton();
				}
			case PUSH:
				if (this.menuButton) {
					SplitMenuButton b = new SplitMenuButton();
					return b;
				} else {
					return new Button();
				}
			case RADIO:
				return new RadioButton();
			default:
				break;
			}
			return null;
		}

		@Override
		public void addStyleClasses(List<String> classnames) {
			getWidget().getStyleClass().addAll(classnames);
		}

		@Override
		public void addStyleClasses(String... classnames) {
			getWidget().getStyleClass().addAll(classnames);
		}

		@Override
		public void setStyleId(String id) {
			getWidget().setId(id);
		}

		@Override
		protected void setUserData(WWidgetImpl<ButtonBase, MToolItem> widget) {
			getWidget().setUserData(widget);
		}
	}
}
