#!/usr/bin/env python3
"""
Lua Standalone Script Generator

This script takes a Lua script as input and recursively resolves all Import()
statements to create a single standalone version of the script.

Usage:
    python3 make_standalone.py <input_lua_file>

Example:
    python3 make_standalone.py ../IUIDWand.lua
    # Creates: ../IUIDWand_STANDALONE.lua
"""

import sys
sys.setrecursionlimit(100000)
import os
import re
from pathlib import Path
from typing import Set, List, Tuple, Dict, Optional


class LuaStandaloneGenerator:
    """Generates standalone Lua scripts by resolving all imports."""
    
    def __init__(self, input_file: str, base_dir: str = None, remove_locals: bool = False):
        """
        Initialize the generator.
        
        Args:
            input_file: Path to the input Lua script
            base_dir: Base directory for resolving imports (defaults to input file's directory)
            remove_locals: If true, remove all local qualifiers from the final output
        """
        self.input_file = Path(input_file).resolve()
        self.base_dir = Path(base_dir or self.input_file.parent)
        self.processed_modules: Set[str] = set()
        self.import_pattern = re.compile(r"local\s+(\w+)\s*=\s*Import\s*\(\s*['\"](\w+)['\"]\s*\)")
        self.export_pattern = re.compile(r"-+\s*Export\s*-+")
        self.remove_locals = remove_locals
        self.function_def_pattern = re.compile(r"local\s+function\s+(\w+)\s*\(")
        self.local_var_pattern = re.compile(r"local\s+(\w+)\s*=")
        # Map of module path -> (list of exported names, module alias used in that module)
        self.module_exports: Dict[str, List[str]] = {}
        # Map of module path -> dict of variable_name -> module_name for imports within that module
        self.module_imports: Dict[str, Dict[str, str]] = {}
        # Set of imported module name prefixes, e.g. 'IPLib_'
        self.imported_prefixes: Set[str] = set()
        
        if not self.input_file.exists():
            raise FileNotFoundError(f"Input file not found: {self.input_file}")
    
    def resolve_module_path(self, module_name: str) -> Path:
        """
        Resolve the full path to a module given its name.
        
        Args:
            module_name: The name of the module (without .lua extension)
            
        Returns:
            Path object pointing to the module file
        """
        module_path = self.base_dir / f"{module_name}.lua"
        return module_path
    
    def read_file(self, file_path: Path) -> str:
        """Read a Lua file and return its contents."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            raise IOError(f"Error reading file {file_path}: {e}")
    
    def write_file(self, file_path: Path, content: str) -> None:
        """Write content to a file."""
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
        except Exception as e:
            raise IOError(f"Error writing file {file_path}: {e}")
    
    def extract_exports(self, content: str) -> List[str]:
        """
        Extract exported function and variable names from a module.
        
        Args:
            content: The module content
            
        Returns:
            List of exported function and variable names (without the _ suffix)
        """
        # Find the Export section
        export_match = self.export_pattern.search(content)
        if not export_match:
            return []
        
        export_start = export_match.end()
        
        # Look for the table assignment after Export
        try:
            table_match = re.search(r"local\s+(\w+)\s*=\s*\{([^}]*)\}", content[export_start:])
        except Exception as e:
            raise ValueError(f"table_match re.search failed: {e}")
        if not table_match:
            return []
        
        table_content = table_match.group(2)
        # Extract all function and variable names from the table
        # Pattern: name = name_ or name = name_,
        exported = []
        try:
            for match in re.finditer(r"(\w+)\s*=\s*(\w+)_", table_content):
                exported.append(match.group(1))
        except Exception as e:
            raise ValueError(f"re.finditer failed: {e}")
        
        return exported
    
    def extract_imports(self, content: str) -> Dict[str, str]:
        """
        Extract import statements and return mapping of variable -> module name.
        
        Args:
            content: The module content
            
        Returns:
            Dictionary mapping variable names to module names
        """
        imports = {}
        for match in self.import_pattern.finditer(content):
            var_name = match.group(1)
            module_name = match.group(2)
            imports[var_name] = module_name
        return imports
    
    def remove_export_section(self, content: str) -> str:
        """
        Remove the Export section from module content.
        
        Args:
            content: The module content
            
        Returns:
            Content with Export section removed
        """
        # Find the Export section
        export_match = self.export_pattern.search(content)
        if not export_match:
            return content
        
        export_start = export_match.start()
        
        # Find the corresponding return statement
        return_match = re.search(r"return\s+\w+", content[export_start:])
        if not return_match:
            return content
        
        return_end = export_start + return_match.end()
        
        # Remove from Export section to end (including return statement)
        return content[:export_start] + content[return_end:]
    
    def rename_functions_and_variables(self, content: str, module_name: str, exported_names: List[str]) -> str:
        """
        Rename all exported functions and variables by adding module prefix and removing _ suffix.
        Only rename module-level variables, not function parameters or local variables inside functions.
        
        Args:
            content: The module content
            module_name: The module name to use as prefix
            exported_names: List of names that are exported from this module
            
        Returns:
            Content with renamed functions and variables
        """
        lines = content.split('\n')
        output_lines = []
        
        # Track function and variable names for later replacement
        function_names = []
        variable_names = []
        
        # Track nesting depth to identify module-level vs function-level variables
        nesting_depth = 0
        
        for line in lines:
            # Update nesting depth
            if re.search(r"\b(function|if|for|while|repeat|do)\b", line):
                nesting_depth += line.count('function') + line.count('if') + line.count('for') + line.count('while') + line.count('repeat') + line.count('do')
            if re.search(r"\b(end|until)\b", line):
                nesting_depth -= line.count('end') + line.count('until')
            
            # Check for function definitions: local function name_()
            func_match = self.function_def_pattern.search(line)
            if func_match:
                func_name = func_match.group(1)
                if func_name.endswith('_'):
                    # Remove the _ suffix and add module prefix
                    new_name = func_name[:-1]
                    prefixed_name = f"{module_name}_{new_name}"
                    function_names.append((func_name, prefixed_name))
                    line = line.replace(f"function {func_name}", f"function {prefixed_name}")
            
            # Only rename module-level local variables (not inside functions)
            if nesting_depth == 0 and "local function" not in line:
                var_match = self.local_var_pattern.search(line)
                if var_match:
                    var_name = var_match.group(1)
                    # Skip very short variable names to avoid ambiguous word boundary replacements
                    if len(var_name) >= 3:
                        # Rename all local variables in imported modules
                        if var_name.endswith('_'):
                            # Remove the _ suffix and add module prefix
                            new_name = var_name[:-1]
                            prefixed_name = f"{module_name}_{new_name}"
                            variable_names.append((var_name, prefixed_name))
                            # Replace in the context of local declaration to avoid replacing inside keywords
                            line = re.sub(rf"(local\s+){re.escape(var_name)}(\s*=)", rf"\1{prefixed_name}\2", line, count=1)
                        elif not var_name.endswith('_') and var_name not in ['nil', 'true', 'false']:
                            # For variables that don't end with _, also add prefix if they're not Lua keywords
                            prefixed_name = f"{module_name}_{var_name}"
                            variable_names.append((var_name, prefixed_name))
                            # Replace in the context of local declaration to avoid replacing inside keywords
                            line = re.sub(rf"(local\s+){re.escape(var_name)}(\s*=)", rf"\1{prefixed_name}\2", line, count=1)
            
            output_lines.append(line)
        
        content = '\n'.join(output_lines)
        
        # Replace all references to these functions in a safe order.
        # Use whole-word matching and longest-old-name-first to avoid prefixing
        # substrings of longer identifiers.
        function_names.sort(key=lambda pair: len(pair[0]), reverse=True)
        for old_name, new_name in function_names:
            content = re.sub(rf"\b{re.escape(old_name)}\b", new_name, content)
            # Replace table references in export section (already removed but for safety)
            content = re.sub(rf"\b=\s*{re.escape(old_name)}\b", f"= {new_name}", content)
        
        variable_names.sort(key=lambda pair: len(pair[0]), reverse=True)
        for old_name, new_name in variable_names:
            content = re.sub(rf"\b{re.escape(old_name)}\b", new_name, content)
        
        return content
    
    def remove_comments_from_imported(self, content: str) -> str:
        """
        Remove Lua comments from imported module content only at top level.
        Preserve comments inside function bodies and table/structure literals.
        """
        cleaned_lines = []
        function_depth = 0
        table_depth = 0

        def count_keyword(text: str, keyword: str) -> int:
            return len(re.findall(rf"\b{keyword}\b", text))

        def count_braces(text: str) -> Tuple[int, int]:
            open_count = 0
            close_count = 0
            i = 0
            in_single = False
            in_double = False
            escape = False
            while i < len(text):
                ch = text[i]
                if escape:
                    escape = False
                    i += 1
                    continue
                if ch == '\\':
                    escape = True
                    i += 1
                    continue
                if not in_single and not in_double:
                    if ch == '"':
                        in_double = True
                    elif ch == "'":
                        in_single = True
                    elif ch == '{':
                        open_count += 1
                    elif ch == '}':
                        close_count += 1
                elif in_single and ch == "'":
                    in_single = False
                elif in_double and ch == '"':
                    in_double = False
                i += 1
            return open_count, close_count

        for line in content.split('\n'):
            i = 0
            in_single = False
            in_double = False
            escape = False
            comment_start = len(line)
            while i < len(line):
                ch = line[i]
                if escape:
                    escape = False
                    i += 1
                    continue
                if ch == '\\':
                    escape = True
                    i += 1
                    continue
                if not in_single and not in_double:
                    if ch == '"':
                        in_double = True
                        i += 1
                        continue
                    if ch == "'":
                        in_single = True
                        i += 1
                        continue
                    if ch == '-' and i + 1 < len(line) and line[i + 1] == '-':
                        comment_start = i
                        break
                elif in_single:
                    if ch == "'":
                        in_single = False
                elif in_double:
                    if ch == '"':
                        in_double = False
                i += 1

            code_portion = line[:comment_start]
            open_braces, close_braces = count_braces(code_portion)
            current_table_depth = table_depth + (open_braces - close_braces)
            current_function_depth = function_depth + count_keyword(code_portion, 'function') - count_keyword(code_portion, 'end')

            inside_function = current_function_depth > 0
            inside_table = current_table_depth > 0
            if inside_function or inside_table:
                cleaned_line = line.rstrip()
            else:
                cleaned_line = code_portion.rstrip()

            cleaned_lines.append(cleaned_line)

            table_depth += open_braces - close_braces
            if table_depth < 0:
                table_depth = 0

            function_depth += count_keyword(code_portion, 'function')
            function_depth -= count_keyword(code_portion, 'end')
            if function_depth < 0:
                function_depth = 0

        return '\n'.join(cleaned_lines)

    def remove_unused_functions_and_variables(self, content: str) -> str:
        """
        Remove functions and variables that are defined but never used.
        Performs a single pass removal.
        
        Args:
            content: The content to process
            
        Returns:
            Content with unused functions and variables removed
        """
        previous_content = None
        current_content = content

        while current_content != previous_content:
            previous_content = current_content
            lines = current_content.split('\n')
            output_lines = []
            
            # Track all defined functions and variables
            defined_functions = set()
            defined_variables = set()
            
            # Track only imported definitions for removal
            imported_defined_functions = set()
            imported_defined_variables = set()
            
            # Track all usages
            used_names = set()
            
            # First pass: collect definitions
            for line in lines:
                try:
                    # Find function definitions: local function name(
                    func_match = re.search(r"local\s+function\s+(\w+)\s*\(", line)
                except Exception as e:
                    raise ValueError(f"re.search failed on line: {repr(line)} : {e}")
                if func_match:
                    func_name = func_match.group(1)
                    defined_functions.add(func_name)
                    if any(func_name.startswith(prefix) for prefix in self.imported_prefixes):
                        imported_defined_functions.add(func_name)
                
                try:
                    # Find variable definitions: local name = 
                    var_match = re.search(r"local\s+(\w+)\s*=", line)
                except Exception as e:
                    raise ValueError(f"var re.search failed on line: {repr(line)} : {e}")
                if var_match:
                    var_name = var_match.group(1)
                    # Don't count function names as variables
                    if var_name not in defined_functions:
                        defined_variables.add(var_name)
                        if any(var_name.startswith(prefix) for prefix in self.imported_prefixes):
                            imported_defined_variables.add(var_name)
            
            # Second pass: collect usages from all lines, but ignore the defined symbol on its own definition line
            for line in lines:
                defined_name = None
                definition_match = re.match(r"\s*local\s+function\s+(\w+)\s*\(", line)
                if definition_match:
                    defined_name = definition_match.group(1)
                    line_to_scan = line[definition_match.end():]
                else:
                    definition_match = re.match(r"\s*local\s+(\w+)\s*=\s*(.*)", line)
                    if definition_match:
                        defined_name = definition_match.group(1)
                        line_to_scan = definition_match.group(2)
                    else:
                        line_to_scan = line

                try:
                    # Find all word usages (potential function/variable references)
                    words = re.findall(r'\b\w+\b', line_to_scan)
                except Exception as e:
                    raise ValueError(f"re.findall failed on line: {repr(line_to_scan)} : {e}")
                for word in words:
                    # Skip keywords and common Lua words
                    if word not in ['local', 'function', 'if', 'then', 'else', 'end', 'for', 'while', 'do', 'return', 'nil', 'true', 'false', 'and', 'or', 'not', 'in', 'pairs', 'ipairs']:
                        used_names.add(word)
                if defined_name is not None and defined_name in used_names:
                    used_names.remove(defined_name)
        
            def is_block_start(line_text: str) -> bool:
                try:
                    return bool(re.search(r"\b(function|if|for|while|repeat|do)\b", line_text))
                except Exception as e:
                    raise ValueError(f"is_block_start failed on line: {repr(line_text)} : {e}")
            
            def is_block_end(line_text: str) -> bool:
                try:
                    return bool(re.search(r"\b(end|until)\b", line_text))
                except Exception as e:
                    raise ValueError(f"is_block_end failed on line: {repr(line_text)} : {e}")
            
            i = 0
            while i < len(lines):
                line = lines[i]
                try:
                    func_match = re.search(r"local\s+function\s+(\w+)\s*\(", line)
                except Exception as e:
                    raise ValueError(f"func_match re.search failed on line: {repr(line)} : {e}")
                if func_match:
                    func_name = func_match.group(1)
                    if func_name in imported_defined_functions and func_name not in used_names:
                        # Skip the entire function block, starting from the function definition itself.
                        depth = 1
                        i += 1
                        while i < len(lines):
                            current_line = lines[i]
                            if is_block_start(current_line):
                                depth += 1
                            if is_block_end(current_line):
                                depth -= 1
                                if depth == 0:
                                    i += 1
                                    break
                            i += 1
                        continue
                try:
                    var_match = re.search(r"local\s+(\w+)\s*=", line)
                except Exception as e:
                    raise ValueError(f"var_match re.search failed on line: {repr(line)} : {e}")
                if var_match:
                    var_name = var_match.group(1)
                    if var_name in imported_defined_variables and var_name not in used_names:
                        i += 1
                        continue
                output_lines.append(line)
                i += 1
            
            current_content = '\n'.join(output_lines)
        
        return current_content

    def collapse_multiple_blank_lines(self, content: str) -> str:
        """
        Collapse consecutive blank lines so there is never more than one empty line in a row.
        """
        lines = content.split('\n')
        output_lines = []
        prev_blank = False
        for line in lines:
            is_blank = line.strip() == ''
            if is_blank:
                if not prev_blank:
                    output_lines.append('')
                prev_blank = True
            else:
                output_lines.append(line)
                prev_blank = False
        return '\n'.join(output_lines)

    def remove_local_qualifiers(self, content: str) -> str:
        """
        Remove local qualifiers from top-level function declarations and top-level variable declarations.
        Keep locals inside function bodies intact.
        """
        output_lines = []
        function_depth = 0

        for line in content.split('\n'):
            # Find comment start outside strings to avoid function/end tokens inside comments.
            i = 0
            in_single = False
            in_double = False
            escape = False
            comment_start = len(line)
            while i < len(line):
                ch = line[i]
                if escape:
                    escape = False
                    i += 1
                    continue
                if ch == '\\':
                    escape = True
                    i += 1
                    continue
                if not in_single and not in_double:
                    if ch == '"':
                        in_double = True
                        i += 1
                        continue
                    if ch == "'":
                        in_single = True
                        i += 1
                        continue
                    if ch == '-' and i + 1 < len(line) and line[i + 1] == '-':
                        comment_start = i
                        break
                elif in_single:
                    if ch == "'":
                        in_single = False
                elif in_double:
                    if ch == '"':
                        in_double = False
                i += 1

            code_portion = line[:comment_start]
            top_level = function_depth == 0
            stripped_code = code_portion
            if top_level:
                stripped_code = re.sub(r"^([ \t]*)local\s+function\b", r"\1function", stripped_code)
                stripped_code = re.sub(r"^([ \t]*)local\s+([A-Za-z_][A-Za-z0-9_]*)\s*=", r"\1\2 =", stripped_code)

            output_lines.append(stripped_code + line[comment_start:])

            # Update function depth using code portion only.
            function_depth += len(re.findall(r"\bfunction\b", code_portion))
            function_depth -= len(re.findall(r"\bend\b", code_portion))
            if function_depth < 0:
                function_depth = 0

        return '\n'.join(output_lines)

    def replace_imported_calls(self, content: str, imports: Dict[str, str], 
                              module_exports: Dict[str, List[str]]) -> str:
        """
        Replace calls to imported modules with the new prefixed function names.
        E.g., ipl.getDurability -> IPLib_getDurability
        
        Args:
            content: The content to process
            imports: Dict of variable_name -> module_name
            module_exports: Dict of module_path -> list of exported names
            
        Returns:
            Content with replaced calls
        """
        for var_name, module_name in imports.items():
            module_path = self.resolve_module_path(module_name)
            module_key = str(module_path.resolve())
            
            # Get exported names for this module
            if module_key in module_exports:
                exported_names = module_exports[module_key]
                # Replace var_name.functionName with ModuleName_functionName
                for func_name in exported_names:
                    replacement = f"{module_name}_{func_name}"
                    content = content.replace(f"{var_name}.{func_name}", replacement)
        
        return content
    
    def process_content(self, content: str, file_path: Path = None, 
                       is_main: bool = True) -> str:
        """
        Recursively process content, resolving all imports.
        
        Args:
            content: The Lua code to process
            file_path: The path of the file being processed (for context)
            is_main: Whether this is the main input file
            
        Returns:
            The processed content with all imports resolved
        """
        if file_path is None:
            file_path = self.input_file
        
        # Store original directory and switch to file's directory for relative imports
        old_base_dir = self.base_dir
        self.base_dir = file_path.parent
        
        # Extract imports from this file
        imports = self.extract_imports(content)
        
        # Get the module name for this file
        module_name = file_path.stem
        module_key = str(file_path.resolve())
        
        lines = content.split('\n')
        output_lines = []
        
        for line in lines:
            match = self.import_pattern.search(line)
            
            if match:
                var_name = match.group(1)
                imported_module_name = match.group(2)
                module_path = self.resolve_module_path(imported_module_name)
                
                # Check if module exists
                if not module_path.exists():
                    print(f"Warning: Module not found: {module_path}", file=sys.stderr)
                    output_lines.append(f"-- {line} (module not found)")
                    continue
                
                # Check if already processed (avoid circular dependencies and duplication)
                module_key_imported = str(module_path.resolve())
                if module_key_imported in self.processed_modules:
                    output_lines.append(f"-- {line} (already included)")
                    continue
                
                self.processed_modules.add(module_key_imported)
                self.imported_prefixes.add(f"{imported_module_name}_")
                
                # Read and recursively process the imported module
                module_content = self.read_file(module_path)
                
                # Extract exports before processing
                exported_names = self.extract_exports(module_content)
                self.module_exports[module_key_imported] = exported_names
                
                # Extract imports within the module
                module_imports = self.extract_imports(module_content)
                self.module_imports[module_key_imported] = module_imports
                
                # Recursively process the module
                processed_module_content = self.process_content(module_content, module_path, is_main=False)
                
                # Remove export section
                processed_module_content = self.remove_export_section(processed_module_content)
                
                # Remove comments from imported module content
                processed_module_content = self.remove_comments_from_imported(processed_module_content)
                
                # Rename functions and variables with module prefix
                processed_module_content = self.rename_functions_and_variables(
                    processed_module_content, imported_module_name, exported_names)
                
                # Replace calls to other imported modules within this module
                processed_module_content = self.replace_imported_calls(
                    processed_module_content, module_imports, self.module_exports)
                
                # Add a separator comment
                output_lines.append(f"\n-- ========================================")
                output_lines.append(f"-- Imported: {imported_module_name}")
                output_lines.append(f"-- ========================================")
                output_lines.append(processed_module_content)
                output_lines.append(f"-- End of: {imported_module_name}")
                output_lines.append(f"-- ========================================\n")
            else:
                output_lines.append(line)
        
        result = '\n'.join(output_lines)
        
        # If this is the main file, replace all imported module calls
        if is_main:
            result = self.replace_imported_calls(result, imports, self.module_exports)
        
        return result
        
    def generate_standalone(self) -> str:
        """
        Generate the standalone version of the input script.
        
        Returns:
            The standalone Lua code as a string
        """
        # Reset processed modules for a fresh generation
        self.processed_modules.clear()
        self.module_exports.clear()
        self.module_imports.clear()
        self.imported_prefixes.clear()
        
        # Read the input file
        input_content = self.read_file(self.input_file)
        
        # Process all imports recursively
        standalone_content = self.process_content(input_content, self.input_file, is_main=True)
        # Keep the full inlined module content for correctness.
        # The unused-code cleanup pass can over-trim nested blocks and produce broken output.
        standalone_content = self.collapse_multiple_blank_lines(standalone_content)
        if self.remove_locals:
            standalone_content = self.remove_local_qualifiers(standalone_content)
        
        return standalone_content
    
    def get_output_path(self) -> Path:
        """
        Get the output file path (input name with _STANDALONE suffix).
        
        Returns:
            Path object for the output file
        """
        stem = self.input_file.stem
        suffix = self.input_file.suffix
        output_name = f"{stem}_STANDALONE{suffix}"
        return self.input_file.parent / output_name
    
    def save_standalone(self) -> Path:
        """
        Generate and save the standalone script.
        
        Returns:
            Path to the generated standalone file
        """
        standalone_content = self.generate_standalone()
        output_path = self.get_output_path()
        
        self.write_file(output_path, standalone_content)
        return output_path


def main():
    """Main entry point for the script."""
    if len(sys.argv) < 2:
        print("Usage: python3 make_standalone.py <input_lua_file> [base_dir] [remove_locals]")
        print()
        print("Arguments:")
        print("  input_lua_file: Path to the input Lua script")
        print("  base_dir (optional): Base directory for resolving imports")
        print("  remove_locals (optional): true/false to strip local qualifiers from final output")
        print()
        print("Example:")
        print("  python3 make_standalone.py ../IUIDWand.lua")
        print("  python3 make_standalone.py ../IUIDWand.lua ../scripts true")
        print("  # Creates: ../IUIDWand_STANDALONE.lua")
        sys.exit(1)
    
    input_file = sys.argv[1]
    base_dir = None
    remove_locals = False
    if len(sys.argv) > 2:
        arg2 = sys.argv[2].strip().lower()
        if arg2 in ['true', '1', 'yes', 'on']:
            remove_locals = True
        else:
            base_dir = sys.argv[2]
    if len(sys.argv) > 3:
        remove_locals = sys.argv[3].strip().lower() in ['true', '1', 'yes', 'on']
    
    try:
        generator = LuaStandaloneGenerator(input_file, base_dir, remove_locals=remove_locals)
        output_path = generator.save_standalone()
        print(f"✓ Successfully created standalone script: {output_path}")
        print(f"  Processed modules: {len(generator.processed_modules)}")
        
    except FileNotFoundError as e:
        print(f"✗ Error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
