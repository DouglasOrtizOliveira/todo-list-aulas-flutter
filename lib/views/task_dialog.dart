import 'package:flutter/material.dart';
import 'package:todo_list/models/task.dart';
import 'package:find_dropdown/find_dropdown.dart';


class TaskDialog extends StatefulWidget {
  final Task task;

  TaskDialog({this.task});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority;

  Task _currentTask = Task();

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _currentTask = Task.fromMap(widget.task.toMap());
    }

    _titleController.text = _currentTask.title;
    _descriptionController.text = _currentTask.description;
    _priority = _currentTask.priority;
  }
 

  @override
  void dispose() {
    super.dispose();
    _titleController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      
      title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefas'),
      content: Form(
        key: _formKey,
        child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
           new TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
              autofocus: true,
              validator: (value) {
              if (value.isEmpty) {
               return 'Insira um título';
              }
                 return null;}
              ),
         
          TextFormField(
              keyboardType: TextInputType.multiline,
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descrição'
              ),
             maxLines: null,
             validator: (value) {
             if (value.isEmpty) {
             return 'Insira uma descrição';
            }
            return null;}),
             
         FindDropdown(
          items: ["1: Sem Prioridade", "2: Baixa Prioridade", "3: Media Prioridade", "4: Acima do Normal", "5: Alta Prioridade"],
          label: "Prioridade",
            onChanged: (String item) => print(_priority),
            selectedItem: _priority,
              ),

              
        ],
      ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Salvar'),
          onPressed: () {
            if (_formKey.currentState.validate()) {
            _currentTask.title = _titleController.value.text;
            _currentTask.description = _descriptionController.text;
            _currentTask.priority = _priority;
            Navigator.of(context).pop(_currentTask);
            }
          },
        ),
      ],
    );
  }
}
