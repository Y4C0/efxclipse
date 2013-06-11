package org.eclipse.fx.ecp.handlers;

import java.util.Collection;

import javax.inject.Named;

import org.eclipse.e4.core.di.annotations.CanExecute;
import org.eclipse.e4.core.di.annotations.Execute;
import org.eclipse.e4.core.di.annotations.Optional;
import org.eclipse.emf.common.command.Command;
import org.eclipse.emf.ecp.core.ECPProject;
import org.eclipse.emf.edit.command.PasteFromClipboardCommand;
import org.eclipse.emf.edit.domain.EditingDomain;
import org.eclipse.fx.ecp.dummy.DummyWorkspace;

public class PasteModelElementsHandler {

	private Command command;
	private EditingDomain editingDomain;

	@CanExecute
	public boolean canAddNewElement(@Optional @Named("modelExplorer.selectedItems") Collection<?> selectedItems) {
		// TODO: get this from ECPWorkspaceManager.getProject()
		ECPProject project = DummyWorkspace.INSTANCE.getProject();
		editingDomain = project.getEditingDomain();

		if (selectedItems.size() == 1) {
			Object selectedItem = selectedItems.iterator().next();
			command = PasteFromClipboardCommand.create(editingDomain, selectedItem, null);
			return command.canExecute();
		}

		return false;
	}

	@Execute
	public void executeCommand() {
		editingDomain.getCommandStack().execute(command);
	}

}
