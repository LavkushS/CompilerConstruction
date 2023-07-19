#include "llvmcodegen.hh"
#include "ast.hh"
#include <iostream>
#include <llvm/Support/FileSystem.h>
#include <llvm/IR/Constant.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/GlobalValue.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Bitcode/BitcodeWriter.h>
#include <vector>

#define MAIN_FUNC compiler->module.getFunction("main")

/*
The documentation for LLVM codegen, and how exactly this file works can be found
ins `docs/llvm.md`
*/

void LLVMCompiler::compile(Node *root)
{
    /* Adding reference to print_i in the runtime library */
    // void printi();
    FunctionType *printi_func_type = FunctionType::get(
        builder.getVoidTy(),
        {builder.getInt64Ty()},
        false);
    Function::Create(
        printi_func_type,
        GlobalValue::ExternalLinkage,
        "printi",
        &module);
    /* we can get this later
        module.getFunction("printi");
    */

    /* Main Function */
    // int main();
    FunctionType *main_func_type = FunctionType::get(
        builder.getInt64Ty(), {}, false /* is vararg */
    );
    Function *main_func = Function::Create(
        main_func_type,
        GlobalValue::ExternalLinkage,
        "main",
        &module);

    // create main function block
    BasicBlock *main_func_entry_bb = BasicBlock::Create(
        *context,
        "entry",
        main_func);

    // move the builder to the start of the main function block
    builder.SetInsertPoint(main_func_entry_bb);

    root->llvm_codegen(this);

    // return 0;
    builder.CreateRet(builder.getInt64(0));
}

void LLVMCompiler::dump()
{
    outs() << module;
}

void LLVMCompiler::write(std::string file_name)
{
    std::error_code EC;
    raw_fd_ostream fout(file_name, EC, sys::fs::OF_None);
    WriteBitcodeToFile(module, fout);
    fout.flush();
    fout.close();
}

//  ┌―――――――――――――――――――――┐  //
//  │ AST -> LLVM Codegen │  //
//  └―――――――――――――――――――――┘  //

// codegen for statements
Value *NodeStmts::llvm_codegen(LLVMCompiler *compiler)
{
    Value *last = nullptr;
    for (auto node : list)
    {
        last = node->llvm_codegen(compiler);
    }

    return last;
}

Value *NodeDebug::llvm_codegen(LLVMCompiler *compiler)
{
    Value *expr = expression->llvm_codegen(compiler);
    Function *printi_func = compiler->module.getFunction("printi");
    compiler->builder.CreateCall(printi_func, {expr});
    return expr;
}

Value *NodeInt::llvm_codegen(LLVMCompiler *compiler)
{
    return compiler->builder.getInt64(value);
}

Value *NodeShort::llvm_codegen(LLVMCompiler *compiler)
{
    return compiler->builder.getInt64(value);
}

Value *NodeLong::llvm_codegen(LLVMCompiler *compiler)
{
    return compiler->builder.getInt64(value);
}

Value *NodeBinOp::llvm_codegen(LLVMCompiler *compiler)
{
    Value *left_expr = left->llvm_codegen(compiler);
    Value *right_expr = right->llvm_codegen(compiler);

    switch (op)
    {
    case PLUS:
        return compiler->builder.CreateAdd(left_expr, right_expr, "addtmp");
    case MINUS:
        return compiler->builder.CreateSub(left_expr, right_expr, "minustmp");
    case MULT:
        return compiler->builder.CreateMul(left_expr, right_expr, "multtmp");
    case DIV:
        return compiler->builder.CreateSDiv(left_expr, right_expr, "divtmp");
    }
}
Value* NodeTest::llvm_codegen(LLVMCompiler* compiler)
{
    return NULL;
}
Value *NodeDecl::llvm_codegen(LLVMCompiler *compiler)
{
    Value *expr = expression->llvm_codegen(compiler);

    IRBuilder<> temp_builder(
        &MAIN_FUNC->getEntryBlock(),
        MAIN_FUNC->getEntryBlock().begin());

    AllocaInst *alloc = temp_builder.CreateAlloca(compiler->builder.getInt64Ty(), 0, identifier);

    compiler->locals[identifier] = alloc;
    compiler->builder.CreateStore(expr, alloc);
    return ConstantInt::get(Type::getInt64Ty(*(compiler->context)), 0);
}

Value *NodeIdent::llvm_codegen(LLVMCompiler *compiler)
{
    AllocaInst *alloc = compiler->locals[identifier];

    // if your LLVM_MAJOR_VERSION >= 14
    return compiler->builder.CreateLoad(compiler->builder.getInt64Ty(), alloc, identifier);
}

Value *NodeIfElse::llvm_codegen(LLVMCompiler *compiler)
{
    
    Value *CondCheck = condition->llvm_codegen(compiler);

    if (!CondCheck)
    {
        return nullptr;
    }

        CondCheck = compiler->builder.CreateICmpNE(
        CondCheck, ConstantInt::get(Type::getInt64Ty(*(compiler->context)), 0), "ifcond");

    
    Function *TheFunction = compiler->builder.GetInsertBlock()->getParent();

    BasicBlock *ifBodyBB = BasicBlock::Create(*compiler->context, "then", TheFunction);
    
    
    
    BasicBlock *elseBodyBB = BasicBlock::Create(*compiler->context, "else");

    BasicBlock *MergeBB = BasicBlock::Create(*compiler->context, "ifcont");
   
   
    compiler->builder.CreateCondBr(CondCheck, ifBodyBB, elseBodyBB);
    compiler->builder.SetInsertPoint(ifBodyBB);
    
    Value *ifBodyNode = ifBody->llvm_codegen(compiler);

    if (!ifBodyNode)
    {

        return nullptr;
    }

    compiler->builder.CreateBr(MergeBB);
    
    ifBodyBB = compiler->builder.GetInsertBlock();

    TheFunction->getBasicBlockList().push_back(elseBodyBB);
    
    compiler->builder.SetInsertPoint(elseBodyBB);

    
    Value *elseBodyNode = elseBody->llvm_codegen(compiler);

    if (!elseBodyNode)
    {
        return nullptr;
    }

    compiler->builder.CreateBr(MergeBB);
    elseBodyBB = compiler->builder.GetInsertBlock();

    TheFunction->getBasicBlockList().push_back(MergeBB);
    compiler->builder.SetInsertPoint(MergeBB);

    
    PHINode *phiNode = compiler->builder.CreatePHI(Type::getInt64Ty(*(compiler->context)), 2, "iftmp");

    phiNode->addIncoming(ifBodyNode, ifBodyBB);
    
    
    
    phiNode->addIncoming(elseBodyNode, elseBodyBB);
    return phiNode;
}

#undef MAIN_FUNC