/*******************************************************************************
 * Copyright (c) 2014 BestSolution.at and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Tom Schindl <tom.schindl@bestsolution.at> - initial API and implementation
 *******************************************************************************/
package org.eclipse.fx.ui.viewer;

import java.util.function.Consumer;

public interface ViewerFactory {
	public <O,I,C extends ContentProvider<O, I>, V extends TableViewer<O,I,C>,W> V createTableViewer(W ownerWidget, Consumer<V> setup);
	public <O,I,C extends ContentProvider<O, I>, V extends ListViewer<O,I,C>,W> V createListViewer(W ownerWidget, Consumer<V> setup);
}
