#!/usr/bin/env pwsh
<#
.SYNOPSIS
    crpr - CReate PRoyect: scaffold a ready-to-run project and open it in your editor.

.DESCRIPTION
    Creates a folder under the projects directory and, optionally, generates a
    starter template for a given language. Works on Windows PowerShell 5.1 and
    PowerShell 7+ (pwsh) on Windows, macOS and Linux.

.PARAMETER Name
    Name of the project folder to create (required).

.PARAMETER Language
    Language code to generate a starter template (optional).

.EXAMPLE
    crpr my-api py
    crpr landing html
    crpr just-a-folder

.NOTES
    Configuration via environment variables:
      CRPR_PROJECTS_DIR  Base directory (default: <Home>\Desktop\proyectos)
      CRPR_EDITOR        Editor command (default: code; "none" to skip)
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Name,

    [Parameter(Position = 1)]
    [string]$Language
)

$ErrorActionPreference = 'Stop'

$CrprVersion = '1.0.0'
$CrprRepo = 'https://github.com/tanodev0/crpr'

$SupportedLangs = @(
    'py','js','ts','c','cpp','java','go','rs','rb','sh','html','php','swift',
    'kt','cs','dart','scala','pl','lua','r','jl','hs','ex','erl','clj','groovy',
    'm','fs','pas','f90','nim','cr','zig','v','d','ml','rkt','scm','lisp','tcl',
    'sql','ps1','bat','sol','elm','coffee','vb'
)

$ProjectsDir = if ($env:CRPR_PROJECTS_DIR) { $env:CRPR_PROJECTS_DIR }
               else { Join-Path $HOME 'Desktop/proyectos' }
$EditorCmd = if ($env:CRPR_EDITOR) { $env:CRPR_EDITOR } else { 'code' }

function Show-Usage {
    @"
crpr $CrprVersion - CReate PRoyect

Usage: crpr <project-name> [language]

Options:
  -h, --help     Show this help.
  --langs        List supported language codes.
  --version      Show the version.

Environment:
  CRPR_PROJECTS_DIR  Base directory (default: <Home>\Desktop\proyectos)
  CRPR_EDITOR        Editor command (default: code; "none" to skip)

Examples:
  crpr my-api py
  crpr landing html
  crpr just-a-folder
"@ | Write-Host
}

switch ($Name) {
    { $_ -in '-h', '--help' } { Show-Usage; return }
    '--version'               { Write-Host "crpr $CrprVersion"; return }
    '--langs'                 { Write-Host ($SupportedLangs -join ' '); return }
}

if ([string]::IsNullOrWhiteSpace($Name)) {
    Write-Error "You must provide a project name.`nUsage: crpr <project-name> [language]"
    exit 1
}

$Dest = Join-Path $ProjectsDir $Name

if (Test-Path -LiteralPath $Dest) {
    Write-Host "Note: folder '$Dest' already exists. Opening it as-is."
} else {
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    Write-Host "Created folder: $Dest"
}

function Write-File {
    param([string]$Path, [string]$Content)
    # Write UTF-8 without BOM (works on both Windows PowerShell 5.1 and pwsh 7+).
    $full = Join-Path $Dest $Path
    $dir = Split-Path -Parent $full
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($full, $Content, $utf8NoBom)
}

function Write-Readme {
    param([string]$Lang, [string]$RunHint)
    $content = @"
# $Name

> Generated with [crpr]($CrprRepo) — scaffolds a ready-to-run project and opens it in your editor.

**Language template:** ``$Lang``

## Run

``````sh
$RunHint
``````

> The exact toolchain (compiler/interpreter) must be installed on your system.
"@
    Write-File 'README.md' $content
}

function New-Template {
    param([string]$Lang)

    $Lang = $Lang.ToLower()
    switch ($Lang) {
        'python'      { $Lang = 'py' }
        { $_ -in 'javascript','node','nodejs' } { $Lang = 'js' }
        'typescript'  { $Lang = 'ts' }
        'c++'         { $Lang = 'cpp' }
        'golang'      { $Lang = 'go' }
        'rust'        { $Lang = 'rs' }
        'ruby'        { $Lang = 'rb' }
        { $_ -in 'bash','shell','zsh' } { $Lang = 'sh' }
        'kotlin'      { $Lang = 'kt' }
        { $_ -in 'csharp','c#','dotnet' } { $Lang = 'cs' }
        { $_ -in 'fsharp','f#' } { $Lang = 'fs' }
        'perl'        { $Lang = 'pl' }
        'julia'       { $Lang = 'jl' }
        'haskell'     { $Lang = 'hs' }
        'elixir'      { $Lang = 'ex' }
        'erlang'      { $Lang = 'erl' }
        'clojure'     { $Lang = 'clj' }
        { $_ -in 'objc','objective-c','objectivec' } { $Lang = 'm' }
        'pascal'      { $Lang = 'pas' }
        'fortran'     { $Lang = 'f90' }
        'crystal'     { $Lang = 'cr' }
        'vlang'       { $Lang = 'v' }
        'ocaml'       { $Lang = 'ml' }
        'racket'      { $Lang = 'rkt' }
        'scheme'      { $Lang = 'scm' }
        'commonlisp'  { $Lang = 'lisp' }
        { $_ -in 'powershell','pwsh' } { $Lang = 'ps1' }
        { $_ -in 'batch','cmd' } { $Lang = 'bat' }
        'solidity'    { $Lang = 'sol' }
        'coffeescript' { $Lang = 'coffee' }
        { $_ -in 'visualbasic','vbnet','vb.net' } { $Lang = 'vb' }
    }

    $runHint = ''

    switch ($Lang) {
        'py' {
            Write-File 'main.py' @'
"""Application template generated by crpr."""

from __future__ import annotations

import sys


def greet(name: str) -> str:
    """Return a greeting for the given name."""
    return f"Hello, {name}!"


def sum_to(n: int) -> int:
    """Sum the integers from 1 to n (inclusive)."""
    return sum(range(1, n + 1))


def main(argv: list[str]) -> int:
    names = ["world", "Alice", "Bob"]
    if len(argv) > 1:
        names.append(argv[1])

    for name in names:
        print(greet(name))

    print(f"The sum from 1 to 5 is {sum_to(5)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
'@
            $runHint = 'python main.py'
        }
        'js' {
            Write-File 'package.json' @"
{
  "name": "$Name",
  "version": "1.0.0",
  "description": "Project generated with crpr",
  "main": "index.js",
  "type": "commonjs",
  "scripts": {
    "start": "node index.js"
  }
}
"@
            Write-File 'index.js' @'
// Application template generated by crpr.

function greet(name) {
  return `Hello, ${name}!`;
}

function sumTo(n) {
  let total = 0;
  for (let i = 1; i <= n; i++) total += i;
  return total;
}

function main(args) {
  const names = ["world", "Alice", "Bob"];
  if (args.length > 0) names.push(args[0]);

  for (const name of names) {
    console.log(greet(name));
  }

  console.log(`The sum from 1 to 5 is ${sumTo(5)}`);
}

main(process.argv.slice(2));
'@
            $runHint = 'npm start   # or: node index.js'
        }
        'ts' {
            Write-File 'package.json' @"
{
  "name": "$Name",
  "version": "1.0.0",
  "description": "Project generated with crpr",
  "scripts": {
    "start": "ts-node index.ts"
  }
}
"@
            Write-File 'index.ts' @'
// Application template generated by crpr.

function greet(name: string): string {
  return `Hello, ${name}!`;
}

function sumTo(n: number): number {
  let total = 0;
  for (let i = 1; i <= n; i++) total += i;
  return total;
}

function main(args: string[]): void {
  const names: string[] = ["world", "Alice", "Bob"];
  if (args.length > 0) names.push(args[0]);

  for (const name of names) {
    console.log(greet(name));
  }

  console.log(`The sum from 1 to 5 is ${sumTo(5)}`);
}

main(process.argv.slice(2));
'@
            $runHint = 'npm install && npm start   # requires ts-node'
        }
        'c' {
            Write-File 'main.c' @'
#include <stdio.h>

/* Application template generated by crpr. */

void greet(const char *name) {
    printf("Hello, %s!\n", name);
}

int sum_to(int n) {
    int total = 0;
    for (int i = 1; i <= n; i++) total += i;
    return total;
}

int main(int argc, char *argv[]) {
    const char *names[] = {"world", "Alice", "Bob"};
    int n = sizeof(names) / sizeof(names[0]);

    for (int i = 0; i < n; i++) greet(names[i]);
    if (argc > 1) greet(argv[1]);

    printf("The sum from 1 to 5 is %d\n", sum_to(5));
    return 0;
}
'@
            $runHint = 'cc main.c -o app && ./app'
        }
        'cpp' {
            Write-File 'main.cpp' @'
#include <iostream>
#include <string>
#include <vector>

// Application template generated by crpr.

std::string greet(const std::string &name) {
    return "Hello, " + name + "!";
}

int sum_to(int n) {
    int total = 0;
    for (int i = 1; i <= n; ++i) total += i;
    return total;
}

int main(int argc, char *argv[]) {
    std::vector<std::string> names{"world", "Alice", "Bob"};
    if (argc > 1) names.push_back(argv[1]);

    for (const auto &name : names) {
        std::cout << greet(name) << '\n';
    }

    std::cout << "The sum from 1 to 5 is " << sum_to(5) << '\n';
    return 0;
}
'@
            $runHint = 'c++ main.cpp -o app && ./app'
        }
        'java' {
            Write-File 'Main.java' @'
import java.util.ArrayList;
import java.util.List;

// Application template generated by crpr.
public class Main {

    static String greet(String name) {
        return "Hello, " + name + "!";
    }

    static int sumTo(int n) {
        int total = 0;
        for (int i = 1; i <= n; i++) total += i;
        return total;
    }

    public static void main(String[] args) {
        List<String> names = new ArrayList<>(List.of("world", "Alice", "Bob"));
        if (args.length > 0) names.add(args[0]);

        for (String name : names) {
            System.out.println(greet(name));
        }

        System.out.println("The sum from 1 to 5 is " + sumTo(5));
    }
}
'@
            $runHint = 'javac Main.java && java Main'
        }
        'go' {
            Write-File 'go.mod' @"
module $Name

go 1.22
"@
            Write-File 'main.go' @'
package main

import (
    "fmt"
    "os"
)

// greet returns a greeting for the given name.
func greet(name string) string {
    return fmt.Sprintf("Hello, %s!", name)
}

// sumTo sums the integers from 1 to n.
func sumTo(n int) int {
    total := 0
    for i := 1; i <= n; i++ {
        total += i
    }
    return total
}

func main() {
    names := []string{"world", "Alice", "Bob"}
    if len(os.Args) > 1 {
        names = append(names, os.Args[1])
    }

    for _, name := range names {
        fmt.Println(greet(name))
    }

    fmt.Printf("The sum from 1 to 5 is %d\n", sumTo(5))
}
'@
            $runHint = 'go run .'
        }
        'rs' {
            Write-File 'Cargo.toml' @"
[package]
name = "$Name"
version = "0.1.0"
edition = "2021"

[dependencies]
"@
            Write-File 'src/main.rs' @'
//! Application template generated by crpr.

use std::env;

fn greet(name: &str) -> String {
    format!("Hello, {name}!")
}

fn sum_to(n: u32) -> u32 {
    (1..=n).sum()
}

fn main() {
    let mut names: Vec<String> =
        vec!["world".into(), "Alice".into(), "Bob".into()];
    if let Some(arg) = env::args().nth(1) {
        names.push(arg);
    }

    for name in &names {
        println!("{}", greet(name));
    }

    println!("The sum from 1 to 5 is {}", sum_to(5));
}
'@
            $runHint = 'cargo run'
        }
        'rb' {
            Write-File 'main.rb' @'
# frozen_string_literal: true

# Application template generated by crpr.

def greet(name)
  "Hello, #{name}!"
end

def sum_to(n)
  (1..n).sum
end

def main(args)
  names = %w[world Alice Bob]
  names << args[0] unless args.empty?

  names.each { |name| puts greet(name) }
  puts "The sum from 1 to 5 is #{sum_to(5)}"
end

main(ARGV)
'@
            $runHint = 'ruby main.rb'
        }
        'sh' {
            Write-File 'main.sh' @'
#!/usr/bin/env bash
#
# Application template generated by crpr.
set -euo pipefail

greet() {
  printf 'Hello, %s!\n' "$1"
}

sum_to() {
  local n="$1" total=0 i
  for ((i = 1; i <= n; i++)); do
    total=$((total + i))
  done
  printf '%s' "$total"
}

main() {
  local names=("world" "Alice" "Bob")
  if [ "$#" -gt 0 ]; then
    names+=("$1")
  fi

  for name in "${names[@]}"; do
    greet "$name"
  done

  printf 'The sum from 1 to 5 is %s\n' "$(sum_to 5)"
}

main "$@"
'@
            $runHint = 'bash main.sh'
        }
        'html' {
            Write-File 'index.html' @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Project</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <main class="container">
    <h1>Hello, world!</h1>
    <p>Template generated by <code>crpr</code>.</p>
    <ul id="list"></ul>
  </main>
  <script src="script.js"></script>
</body>
</html>
'@
            Write-File 'style.css' @'
:root {
  --bg: #0f172a;
  --fg: #e2e8f0;
  --accent: #38bdf8;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  min-height: 100vh;
  display: grid;
  place-items: center;
  font-family: system-ui, -apple-system, sans-serif;
  background: var(--bg);
  color: var(--fg);
}

.container {
  text-align: center;
  padding: 2rem;
}

h1 {
  color: var(--accent);
}

#list {
  list-style: none;
  padding: 0;
}

#list li {
  padding: 0.25rem 0;
}
'@
            Write-File 'script.js' @'
// Application template generated by crpr.

function greet(name) {
  return `Hello, ${name}!`;
}

const names = ["world", "Alice", "Bob"];
const list = document.getElementById("list");

for (const name of names) {
  const li = document.createElement("li");
  li.textContent = greet(name);
  list.appendChild(li);
}

console.log("App started.");
'@
            $runHint = 'start index.html   # Windows (macOS: open index.html)'
        }
        'php' {
            Write-File 'index.php' @'
<?php

declare(strict_types=1);

// Application template generated by crpr.

function greet(string $name): string
{
    return "Hello, {$name}!";
}

function sumTo(int $n): int
{
    $total = 0;
    for ($i = 1; $i <= $n; $i++) {
        $total += $i;
    }
    return $total;
}

$names = ['world', 'Alice', 'Bob'];
foreach ($names as $name) {
    echo greet($name) . PHP_EOL;
}

echo 'The sum from 1 to 5 is ' . sumTo(5) . PHP_EOL;
'@
            $runHint = 'php index.php'
        }
        'swift' {
            Write-File 'main.swift' @'
import Foundation

// Application template generated by crpr.

func greet(_ name: String) -> String {
    return "Hello, \(name)!"
}

func sumTo(_ n: Int) -> Int {
    return (1...n).reduce(0, +)
}

var names = ["world", "Alice", "Bob"]
if CommandLine.arguments.count > 1 {
    names.append(CommandLine.arguments[1])
}

for name in names {
    print(greet(name))
}

print("The sum from 1 to 5 is \(sumTo(5))")
'@
            $runHint = 'swift main.swift'
        }
        'kt' {
            Write-File 'Main.kt' @'
// Application template generated by crpr.

fun greet(name: String): String = "Hello, $name!"

fun sumTo(n: Int): Int = (1..n).sum()

fun main(args: Array<String>) {
    val names = mutableListOf("world", "Alice", "Bob")
    if (args.isNotEmpty()) names.add(args[0])

    names.forEach { println(greet(it)) }
    println("The sum from 1 to 5 is ${sumTo(5)}")
}
'@
            $runHint = 'kotlinc Main.kt -include-runtime -d app.jar && java -jar app.jar'
        }
        'cs' {
            Write-File "$Name.csproj" @'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
'@
            Write-File 'Program.cs' @'
using System;
using System.Collections.Generic;
using System.Linq;

// Application template generated by crpr.
class Program
{
    static string Greet(string name) => $"Hello, {name}!";

    static int SumTo(int n) => Enumerable.Range(1, n).Sum();

    static void Main(string[] args)
    {
        var names = new List<string> { "world", "Alice", "Bob" };
        if (args.Length > 0) names.Add(args[0]);

        foreach (var name in names)
            Console.WriteLine(Greet(name));

        Console.WriteLine($"The sum from 1 to 5 is {SumTo(5)}");
    }
}
'@
            $runHint = 'dotnet run'
        }
        'dart' {
            Write-File 'main.dart' @'
// Application template generated by crpr.

String greet(String name) => 'Hello, $name!';

int sumTo(int n) =>
    List.generate(n, (i) => i + 1).fold(0, (a, b) => a + b);

void main(List<String> args) {
  final names = ['world', 'Alice', 'Bob'];
  if (args.isNotEmpty) names.add(args[0]);

  for (final name in names) {
    print(greet(name));
  }

  print('The sum from 1 to 5 is ${sumTo(5)}');
}
'@
            $runHint = 'dart run main.dart'
        }
        'scala' {
            Write-File 'Main.scala' @'
// Application template generated by crpr.

object Main {
  def greet(name: String): String = s"Hello, $name!"

  def sumTo(n: Int): Int = (1 to n).sum

  def main(args: Array[String]): Unit = {
    val names = List("world", "Alice", "Bob") ++ args.headOption.toList
    names.foreach(name => println(greet(name)))
    println(s"The sum from 1 to 5 is ${sumTo(5)}")
  }
}
'@
            $runHint = 'scala Main.scala'
        }
        'pl' {
            Write-File 'main.pl' @'
#!/usr/bin/env perl
# Application template generated by crpr.
use strict;
use warnings;
use List::Util qw(sum);

sub greet {
    my ($name) = @_;
    return "Hello, $name!";
}

sub sum_to {
    my ($n) = @_;
    return sum(1 .. $n);
}

my @names = ("world", "Alice", "Bob");
push @names, $ARGV[0] if @ARGV;

print greet($_), "\n" for @names;
printf "The sum from 1 to 5 is %d\n", sum_to(5);
'@
            $runHint = 'perl main.pl'
        }
        'lua' {
            Write-File 'main.lua' @'
-- Application template generated by crpr.

local function greet(name)
  return "Hello, " .. name .. "!"
end

local function sum_to(n)
  local total = 0
  for i = 1, n do
    total = total + i
  end
  return total
end

local names = { "world", "Alice", "Bob" }
if arg[1] then
  table.insert(names, arg[1])
end

for _, name in ipairs(names) do
  print(greet(name))
end

print("The sum from 1 to 5 is " .. sum_to(5))
'@
            $runHint = 'lua main.lua'
        }
        'r' {
            Write-File 'main.R' @'
# Application template generated by crpr.

greet <- function(name) {
  paste0("Hello, ", name, "!")
}

sum_to <- function(n) {
  sum(1:n)
}

names_list <- c("world", "Alice", "Bob")
args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  names_list <- c(names_list, args[1])
}

for (name in names_list) {
  cat(greet(name), "\n")
}

cat("The sum from 1 to 5 is", sum_to(5), "\n")
'@
            $runHint = 'Rscript main.R'
        }
        'jl' {
            Write-File 'main.jl' @'
# Application template generated by crpr.

greet(name) = "Hello, $name!"

sum_to(n) = sum(1:n)

function main(args)
    names = ["world", "Alice", "Bob"]
    if !isempty(args)
        push!(names, args[1])
    end

    for name in names
        println(greet(name))
    end

    println("The sum from 1 to 5 is ", sum_to(5))
end

main(ARGS)
'@
            $runHint = 'julia main.jl'
        }
        'hs' {
            Write-File 'Main.hs' @'
-- Application template generated by crpr.
module Main (main) where

import System.Environment (getArgs)

greet :: String -> String
greet name = "Hello, " ++ name ++ "!"

sumTo :: Int -> Int
sumTo n = sum [1 .. n]

main :: IO ()
main = do
  args <- getArgs
  let names = ["world", "Alice", "Bob"] ++ take 1 args
  mapM_ (putStrLn . greet) names
  putStrLn ("The sum from 1 to 5 is " ++ show (sumTo 5))
'@
            $runHint = 'runghc Main.hs'
        }
        'ex' {
            Write-File 'main.exs' @'
# Application template generated by crpr.
defmodule App do
  def greet(name), do: "Hello, #{name}!"

  def sum_to(n), do: Enum.sum(1..n)

  def run(args) do
    names = ["world", "Alice", "Bob"] ++ Enum.take(args, 1)
    Enum.each(names, fn name -> IO.puts(greet(name)) end)
    IO.puts("The sum from 1 to 5 is #{sum_to(5)}")
  end
end

App.run(System.argv())
'@
            $runHint = 'elixir main.exs'
        }
        'erl' {
            Write-File 'main.erl' @'
%% Application template generated by crpr.
-module(main).
-export([start/0]).

greet(Name) ->
    "Hello, " ++ Name ++ "!".

sum_to(N) ->
    lists:sum(lists:seq(1, N)).

start() ->
    Names = ["world", "Alice", "Bob"],
    lists:foreach(fun(N) -> io:format("~s~n", [greet(N)]) end, Names),
    io:format("The sum from 1 to 5 is ~p~n", [sum_to(5)]).
'@
            $runHint = 'erlc main.erl && erl -noshell -s main start -s init stop'
        }
        'clj' {
            Write-File 'main.clj' @'
;; Application template generated by crpr.
(ns main)

(defn greet [name]
  (str "Hello, " name "!"))

(defn sum-to [n]
  (reduce + (range 1 (inc n))))

(defn -main [& args]
  (let [names (concat ["world" "Alice" "Bob"] (take 1 args))]
    (doseq [name names]
      (println (greet name)))
    (println "The sum from 1 to 5 is" (sum-to 5))))

(-main)
'@
            $runHint = 'clojure -M main.clj'
        }
        'groovy' {
            Write-File 'main.groovy' @'
// Application template generated by crpr.

def greet(name) {
    "Hello, $name!"
}

def sumTo(n) {
    (1..n).sum()
}

def names = ["world", "Alice", "Bob"]
if (args.length > 0) names << args[0]

names.each { println greet(it) }
println "The sum from 1 to 5 is ${sumTo(5)}"
'@
            $runHint = 'groovy main.groovy'
        }
        'm' {
            Write-File 'main.m' @'
#import <Foundation/Foundation.h>

// Application template generated by crpr.

NSString *greet(NSString *name) {
    return [NSString stringWithFormat:@"Hello, %@!", name];
}

NSInteger sumTo(NSInteger n) {
    NSInteger total = 0;
    for (NSInteger i = 1; i <= n; i++) total += i;
    return total;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSArray<NSString *> *names = @[@"world", @"Alice", @"Bob"];
        for (NSString *name in names) {
            printf("%s\n", [greet(name) UTF8String]);
        }
        printf("The sum from 1 to 5 is %ld\n", (long)sumTo(5));
    }
    return 0;
}
'@
            $runHint = 'cc main.m -framework Foundation -o app && ./app'
        }
        'fs' {
            Write-File "$Name.fsproj" @'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>
</Project>
'@
            Write-File 'Program.fs' @'
// Application template generated by crpr.
module Program

let greet name = sprintf "Hello, %s!" name

let sumTo n = List.sum [ 1 .. n ]

[<EntryPoint>]
let main argv =
    let names = [ "world"; "Alice"; "Bob" ] @ (argv |> Array.toList |> List.truncate 1)
    names |> List.iter (greet >> printfn "%s")
    printfn "The sum from 1 to 5 is %d" (sumTo 5)
    0
'@
            $runHint = 'dotnet run'
        }
        'pas' {
            Write-File 'main.pas' @'
program Main;
{ Application template generated by crpr. }

function Greet(name: string): string;
begin
  Greet := 'Hello, ' + name + '!';
end;

function SumTo(n: Integer): Integer;
var
  i, total: Integer;
begin
  total := 0;
  for i := 1 to n do
    total := total + i;
  SumTo := total;
end;

var
  names: array[0..2] of string = ('world', 'Alice', 'Bob');
  i: Integer;
begin
  for i := 0 to High(names) do
    writeln(Greet(names[i]));
  writeln('The sum from 1 to 5 is ', SumTo(5));
end.
'@
            $runHint = 'fpc main.pas && ./main'
        }
        'f90' {
            Write-File 'main.f90' @'
! Application template generated by crpr.
program main
    implicit none
    character(len=5), parameter :: names(3) = ["world", "Alice", "Bob  "]
    integer :: i

    do i = 1, size(names)
        print '(A)', "Hello, " // trim(names(i)) // "!"
    end do

    print '(A, I0)', "The sum from 1 to 5 is ", sum_to(5)

contains

    integer function sum_to(n) result(total)
        integer, intent(in) :: n
        integer :: j
        total = 0
        do j = 1, n
            total = total + j
        end do
    end function sum_to
end program main
'@
            $runHint = 'gfortran main.f90 -o app && ./app'
        }
        'nim' {
            Write-File 'main.nim' @'
# Application template generated by crpr.
import std/os

proc greet(name: string): string =
  "Hello, " & name & "!"

proc sumTo(n: int): int =
  for i in 1 .. n:
    result += i

var names = @["world", "Alice", "Bob"]
if paramCount() > 0:
  names.add(paramStr(1))

for name in names:
  echo greet(name)

echo "The sum from 1 to 5 is ", sumTo(5)
'@
            $runHint = 'nim c -r main.nim'
        }
        'cr' {
            Write-File 'main.cr' @'
# Application template generated by crpr.

def greet(name : String) : String
  "Hello, #{name}!"
end

def sum_to(n : Int32) : Int32
  (1..n).sum
end

names = ["world", "Alice", "Bob"]
names << ARGV[0] unless ARGV.empty?

names.each do |name|
  puts greet(name)
end

puts "The sum from 1 to 5 is #{sum_to(5)}"
'@
            $runHint = 'crystal run main.cr'
        }
        'zig' {
            Write-File 'main.zig' @'
// Application template generated by crpr.
const std = @import("std");

fn sumTo(n: u32) u32 {
    var total: u32 = 0;
    var i: u32 = 1;
    while (i <= n) : (i += 1) {
        total += i;
    }
    return total;
}

pub fn main() void {
    const names = [_][]const u8{ "world", "Alice", "Bob" };
    for (names) |name| {
        std.debug.print("Hello, {s}!\n", .{name});
    }
    std.debug.print("The sum from 1 to 5 is {d}\n", .{sumTo(5)});
}
'@
            $runHint = 'zig run main.zig'
        }
        'v' {
            Write-File 'main.v' @'
// Application template generated by crpr.
module main

import os

fn greet(name string) string {
    return 'Hello, ${name}!'
}

fn sum_to(n int) int {
    mut total := 0
    for i in 1 .. n + 1 {
        total += i
    }
    return total
}

fn main() {
    mut names := ['world', 'Alice', 'Bob']
    if os.args.len > 1 {
        names << os.args[1]
    }
    for name in names {
        println(greet(name))
    }
    println('The sum from 1 to 5 is ${sum_to(5)}')
}
'@
            $runHint = 'v run main.v'
        }
        'd' {
            Write-File 'main.d' @'
// Application template generated by crpr.
import std.stdio;
import std.algorithm : sum;
import std.range : iota;

string greet(string name) {
    return "Hello, " ~ name ~ "!";
}

int sumTo(int n) {
    return iota(1, n + 1).sum();
}

void main(string[] args) {
    auto names = ["world", "Alice", "Bob"];
    if (args.length > 1) names ~= args[1];

    foreach (name; names) {
        writeln(greet(name));
    }

    writeln("The sum from 1 to 5 is ", sumTo(5));
}
'@
            $runHint = 'rdmd main.d'
        }
        'ml' {
            Write-File 'main.ml' @'
(* Application template generated by crpr. *)

let greet name = "Hello, " ^ name ^ "!"

let sum_to n =
  let rec aux i acc = if i > n then acc else aux (i + 1) (acc + i) in
  aux 1 0

let () =
  let names = [ "world"; "Alice"; "Bob" ] in
  List.iter (fun name -> print_endline (greet name)) names;
  Printf.printf "The sum from 1 to 5 is %d\n" (sum_to 5)
'@
            $runHint = 'ocaml main.ml'
        }
        'rkt' {
            Write-File 'main.rkt' @'
#lang racket
;; Application template generated by crpr.

(define (greet name)
  (string-append "Hello, " name "!"))

(define (sum-to n)
  (apply + (range 1 (add1 n))))

(define names '("world" "Alice" "Bob"))

(for ([name names])
  (displayln (greet name)))

(printf "The sum from 1 to 5 is ~a\n" (sum-to 5))
'@
            $runHint = 'racket main.rkt'
        }
        'scm' {
            Write-File 'main.scm' @'
;; Application template generated by crpr.

(define (greet name)
  (string-append "Hello, " name "!"))

(define (sum-to n)
  (let loop ((i 1) (acc 0))
    (if (> i n) acc (loop (+ i 1) (+ acc i)))))

(define names (list "world" "Alice" "Bob"))

(for-each
  (lambda (name)
    (display (greet name))
    (newline))
  names)

(display "The sum from 1 to 5 is ")
(display (sum-to 5))
(newline)
'@
            $runHint = 'guile main.scm'
        }
        'lisp' {
            Write-File 'main.lisp' @'
;;;; Application template generated by crpr.

(defun greet (name)
  (format nil "Hello, ~a!" name))

(defun sum-to (n)
  (loop for i from 1 to n sum i))

(let ((names '("world" "Alice" "Bob")))
  (dolist (name names)
    (format t "~a~%" (greet name)))
  (format t "The sum from 1 to 5 is ~a~%" (sum-to 5)))
'@
            $runHint = 'sbcl --script main.lisp'
        }
        'tcl' {
            Write-File 'main.tcl' @'
# Application template generated by crpr.

proc greet {name} {
    return "Hello, $name!"
}

proc sum_to {n} {
    set total 0
    for {set i 1} {$i <= $n} {incr i} {
        incr total $i
    }
    return $total
}

set names {world Alice Bob}
foreach name $names {
    puts [greet $name]
}

puts "The sum from 1 to 5 is [sum_to 5]"
'@
            $runHint = 'tclsh main.tcl'
        }
        'sql' {
            Write-File 'main.sql' @'
-- Application template generated by crpr.

-- Example table
CREATE TABLE IF NOT EXISTS people (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

INSERT INTO people (name) VALUES ('world'), ('Alice'), ('Bob');

-- One greeting per person
SELECT 'Hello, ' || name || '!' AS greeting
FROM people;

-- Sum from 1 to 5
SELECT SUM(n) AS sum_1_to_5
FROM (VALUES (1), (2), (3), (4), (5)) AS numbers(n);
'@
            $runHint = 'sqlite3 :memory: ".read main.sql"'
        }
        'ps1' {
            Write-File 'main.ps1' @'
# Application template generated by crpr.

function Get-Greeting {
    param([string]$Name)
    return "Hello, $Name!"
}

function Get-SumTo {
    param([int]$N)
    return (1..$N | Measure-Object -Sum).Sum
}

$names = @('world', 'Alice', 'Bob')
if ($args.Count -gt 0) { $names += $args[0] }

foreach ($name in $names) {
    Write-Host (Get-Greeting -Name $name)
}

Write-Host "The sum from 1 to 5 is $(Get-SumTo -N 5)"
'@
            $runHint = 'pwsh main.ps1'
        }
        'bat' {
            Write-File 'main.bat' @'
@echo off
REM Application template generated by crpr.
setlocal enabledelayedexpansion

for %%n in (world Alice Bob) do (
    echo Hello, %%n!
)

set /a total=0
for /l %%i in (1,1,5) do set /a total+=%%i
echo The sum from 1 to 5 is !total!

endlocal
'@
            $runHint = 'main.bat'
        }
        'sol' {
            Write-File 'Hello.sol' @'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Example contract generated by crpr.
contract Hello {
    string public message;

    event Greeting(address indexed who, string message);

    constructor() {
        message = "Hello, world!";
    }

    function greet(string calldata name) external returns (string memory) {
        string memory g = string.concat("Hello, ", name, "!");
        emit Greeting(msg.sender, g);
        return g;
    }
}
'@
            $runHint = 'solc Hello.sol   # or use Foundry/Hardhat'
        }
        'elm' {
            Write-File 'Main.elm' @'
module Main exposing (main)

-- Application template generated by crpr.

import Html exposing (Html, li, text, ul)


greet : String -> String
greet name =
    "Hello, " ++ name ++ "!"


names : List String
names =
    [ "world", "Alice", "Bob" ]


main : Html msg
main =
    ul [] (List.map (\n -> li [] [ text (greet n) ]) names)
'@
            $runHint = 'elm reactor   # then open Main.elm  (or: elm make Main.elm)'
        }
        'coffee' {
            Write-File 'main.coffee' @'
# Application template generated by crpr.

greet = (name) -> "Hello, #{name}!"

sumTo = (n) ->
  total = 0
  total += i for i in [1..n]
  total

names = ["world", "Alice", "Bob"]
names.push process.argv[2] if process.argv[2]?

console.log greet(name) for name in names
console.log "The sum from 1 to 5 is #{sumTo(5)}"
'@
            $runHint = 'coffee main.coffee'
        }
        'vb' {
            Write-File 'Program.vb' @'
' Application template generated by crpr.
Imports System
Imports System.Collections.Generic

Module Program
    Function Greet(name As String) As String
        Return $"Hello, {name}!"
    End Function

    Function SumTo(n As Integer) As Integer
        Dim total As Integer = 0
        For i As Integer = 1 To n
            total += i
        Next
        Return total
    End Function

    Sub Main(args As String())
        Dim names As New List(Of String) From {"world", "Alice", "Bob"}
        If args.Length > 0 Then names.Add(args(0))

        For Each name In names
            Console.WriteLine(Greet(name))
        Next

        Console.WriteLine($"The sum from 1 to 5 is {SumTo(5)}")
    End Sub
End Module
'@
            $runHint = 'dotnet run   # inside a .NET VB project'
        }
        default {
            Write-Warning "Language '$Language' not recognized. No template generated."
            Write-Host ("Supported: " + ($SupportedLangs -join ' '))
            return $false
        }
    }

    Write-Readme -Lang $Lang -RunHint $runHint
    Write-Host "Generated '$Lang' template in: $Dest"
    return $true
}

if (-not [string]::IsNullOrWhiteSpace($Language)) {
    New-Template -Lang $Language | Out-Null
}

# Open the project in the configured editor.
if ($EditorCmd -eq 'none') {
    # Skip opening.
} elseif (Get-Command $EditorCmd -ErrorAction SilentlyContinue) {
    & $EditorCmd $Dest
} else {
    Write-Warning "Editor command '$EditorCmd' not found; skipping open."
    Write-Host "Set CRPR_EDITOR to your editor (e.g. 'code') or 'none'."
}
