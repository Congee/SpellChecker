#include <Python.h>
#include <structmember.h>

#import <AppKit/AppKit.h>

typedef struct {
	PyObject_HEAD
	const char *word;
	NSSpellChecker *system_checker;
	NSDictionary<NSString *, NSString *> *user_replacements_dictionary;
} SpellChecker;

static void
SpellChecker_dealloc(SpellChecker *self) {
	Py_TYPE(self)->tp_free((PyObject *)self);
}

static PyObject *
SpellChecker_new(PyTypeObject *type, PyObject *args, PyObject *kwargs) {
	SpellChecker *self = (SpellChecker *)type->tp_alloc(type, 0);

	if (self != NULL) {
		self->system_checker = [NSSpellChecker sharedSpellChecker];
		self->user_replacements_dictionary = [self->system_checker userReplacementsDictionary];
	}

	return (PyObject *)self;
}

static PyObject *
guess(SpellChecker *self, PyObject *arg) {
	PyArg_ParseTuple(arg, "s", &self->word);

	NSString *string = @(self->word);
	NSArray<NSString *> *guesses = [self->system_checker guessesForWordRange: NSMakeRange(0, [string length])
																	inString: string
																	language: self->system_checker.language
													  inSpellDocumentWithTag: [NSSpellChecker uniqueSpellDocumentTag]];
	PyObject *list = PyList_New(0);
	for (NSString *word in guesses)
		PyList_Append(list, PyUnicode_FromString([word UTF8String]));

	return list;
}

static PyObject *
complete(SpellChecker *self, PyObject *arg) {
   	PyArg_ParseTuple(arg, "s", &self->word);

	NSString *string = @(self->word);
	NSArray<NSString *> *completions = [self->system_checker completionsForPartialWordRange: NSMakeRange(0, [string length])
																				   inString: string
																				   language: self->system_checker.language
																	 inSpellDocumentWithTag: [NSSpellChecker uniqueSpellDocumentTag]];

	PyObject *list = PyList_New(0);
	for (NSString *word in completions)
		PyList_Append(list, PyUnicode_FromString([word UTF8String]));

	return list;
}

static PyObject *
correct(SpellChecker *self, PyObject *arg) {
	PyArg_ParseTuple(arg, "s", &self->word);

	NSString *string = @(self->word);
	NSString *corrected = [self->system_checker correctionForWordRange: NSMakeRange(0, [string length])
															  inString: string
															  language: self->system_checker.language
												inSpellDocumentWithTag: [NSSpellChecker uniqueSpellDocumentTag]];

	if (corrected)
		return PyUnicode_FromString([corrected UTF8String]);
	else {
		Py_IncRef(Py_None);
		return Py_None;
	}
}

static PyMemberDef SpellChecker_members[] = {
	// do not expose this member
	//{"system_checker", T_OBJECT_EX, offsetof(SpellChecker, system_checker), 0 ,""},
	{NULL, 0, 0, 0, NULL}
};

static PyMethodDef SpellChecker_methods[] = {
	{"complete", (PyCFunction)&complete, METH_VARARGS, "Provides a list of complete words"
														"that the user might be trying to type"
														"based on a partial word in a given string."},
	{"correct", (PyCFunction)&correct, METH_VARARGS, "Returns a single proposed correction if a word is mis-spelled."},
	{"guess", (PyCFunction)&guess, METH_VARARGS, "Returns an array of possible substitutions for the specified string."},
	{NULL, NULL, 0, NULL}
};

static PyTypeObject SpellCheckerType = {
    PyVarObject_HEAD_INIT(NULL, 0)
    "spellcheck.SpellChecker",        /* tp_name */
    sizeof(SpellChecker),             /* tp_basicsize */
    0,                                /* tp_itemsize */
    (destructor)SpellChecker_dealloc, /* tp_dealloc */
    0,                                /* tp_print */
    0,                                /* tp_getattr */
    0,                                /* tp_setattr */
    0,                                /* tp_reserved */
    0,                                /* tp_repr */
    0,                                /* tp_as_number */
    0,                                /* tp_as_sequence */
    0,                                /* tp_as_mapping */
    0,                                /* tp_hash  */
    0,                                /* tp_call */
    0,                                /* tp_str */
    0,                                /* tp_getattro */
    0,                                /* tp_setattro */
    0,                                /* tp_as_buffer */
    Py_TPFLAGS_DEFAULT |
        Py_TPFLAGS_BASETYPE,          /* tp_flags */
    "SpellChecker class",             /* tp_doc */
    0,                                /* tp_traverse */
    0,                                /* tp_clear */
    0,                                /* tp_richcompare */
    0,                                /* tp_weaklistoffset */
    0,                                /* tp_iter */
    0,                                /* tp_iternext */
    SpellChecker_methods,             /* tp_methods */
    SpellChecker_members,             /* tp_members */
    NULL,                             /* tp_getset */
    0,                                /* tp_base */
    0,                                /* tp_dict */
    0,                                /* tp_descr_get */
    0,                                /* tp_descr_set */
    0,                                /* tp_dictoffset */
    NULL,                             /* tp_init */
    0,                                /* tp_alloc */
    SpellChecker_new                  /* tp_new */
};

static PyModuleDef SpellCheck_module = {
	PyModuleDef_HEAD_INIT, /* m_base */
	"spellcheck",          /* m_name */
	"NSSpellChecker",      /* m_doc */
	-1,                    /* m_size */
	NULL,                  /* m_methods */
	NULL,                  /* m_slots */
	NULL,                  /* m_traverse */
	NULL,                  /* m_clear */
	NULL,                  /* m_free */
};

PyMODINIT_FUNC
PyInit_spellcheck(void) {
	PyObject *module = PyModule_Create(&SpellCheck_module);
	if (module == NULL) return NULL;

	if (PyType_Ready(&SpellCheckerType) < 0) return NULL;

	Py_INCREF(&SpellCheckerType);
	PyModule_AddObject(module, "SpellChecker", (PyObject *)&SpellCheckerType);
	return module;
}
